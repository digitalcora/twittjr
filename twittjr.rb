require 'cgi'
require 'time'
require 'open-uri'
require 'rexml/document'

Thread.abort_on_exception = true
$stdout.sync = true

ModemDevice = '/dev/ttyS1'  # Change to e.g. "COM1" for Windows
InitString = 'ATE0S7=30'    # Should work fine for Hayes-compatible modems

buffer = String.new         # Stores the most recent line received from the modem
abort = false               # Set true to signal that the entire program should exit
connected = false           # Set true when a modem connection has been established

# Returns a string representing the approximate distance between the input time and the current time
# (mostly swiped from distance_of_time_in_words in ActionView::Helpers::DateHelper)
def time_ago(from_time)
  to_time = Time.now
  distance_in_minutes = (((to_time - from_time).abs)/60).round
  
  case distance_in_minutes
  when 0               then "less than a minute"
  when 1               then "about a minute"
  when 2..44           then "about #{distance_in_minutes} minutes"
  when 45..89          then "about an hour"
  when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
  when 1440..2879      then "about one day"
  when 2880..43199     then "about #{(distance_in_minutes / 1440).round} days"
  when 43200..86399    then "about one month"
  when 86400..525599   then "about #{(distance_in_minutes / 43200).round} months"
  when 525600..1051199 then "about one year"
  else                      "over #{(distance_in_minutes / 525600).round} years"
  end
end

$modem = File.new(ModemDevice, 'w+')
$modem.sync = true
$modem.print(InitString + "\r\n")

print "Use answer mode (y/n)? "
answer_mode = (gets.chomp.downcase =~ /^y/)
if answer_mode then
  $modem.print("ATS0=1\r\n")  # Turn on auto-answer mode
  puts "Waiting for connection, hit Enter to abort..."
else
  print "Number to dial: "
  dial_number = gets.chomp
  $modem.print("ATDT#{dial_number}\r\n")  # Dial it up!
  puts "Dialing, hit Enter to abort..."
  # If it's been 35 seconds and we're still not connected, abort
  Thread.new {
    sleep(35)
    if not connected then
      puts "Connection timed out!"
      abort = true
    end
  }
end

# Modem thread: Reads data from the modem and responds accordingly
mthread = Thread.new {
  while true do
    buffer = $modem.gets("\r").delete("\r").delete("\n")
    # Use this line for debugging to see what's coming out of the modem
    #puts "Modem> #{buffer}" if not (buffer == "" or buffer =~ /OK/)
    case buffer
    when /CONNECT/
      connected = true
      puts "Connected!"
    when /BUSY/
      puts "Connection failed (line busy)"
      abort = true
    when /NO CARRIER/
      puts connected ? "Connection lost (no carrier)" : "Connection failed (no carrier)"
      abort = true
    when /TSEARCH/
      sep = 254.chr
      search_term = buffer.split(sep)[1]
      open("http://search.twitter.com/search.atom?q=#{CGI.escape(search_term)}&lang=en&rpp=3") do |r|
        xml = REXML::Document.new(r)
        pnum = 0
        xml.elements.each('feed/entry') do |e|
          pnum += 1
          author = e.elements['author'].elements['name'].text
          text = e.elements['title'].text.gsub("\r", " ").gsub("\n", " ")
          time = time_ago(Time.parse(e.elements['published'].text))
          message = "TPOST" + sep + pnum.to_s + sep + author + sep + text + sep + time + " ago\r\n"
          $modem.print(message)
        end
      end
      $modem.print("TDONE\r\n")
    end
  end
}

# Abort thread: Kills everything and resets the modem when 'abort' is set true
Thread.new {
  sleep(0.5) until abort
  mthread.kill
  $modem.print("+++")      # Switch to command mode
  sleep(1.5)               # "+++" must be followed by a delay of at least 1 second
  $modem.print("ATHZ\r\n") # Hang up and reset the modem to defaults
  $modem.close
  exit
}

# Allows the user to manually abort the connection by pressing Enter
gets
abort = true
sleep(0.5) while true
