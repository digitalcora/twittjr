Twittjr Setup
=============

Twittjr is a client/server system that allows an IBM PCjr to search the public timeline on Twitter, with an auto-refreshing display. Visit <http://grantovich.net/projects/twittjr/> for more detailed information. This README is a quick how-to on setting up Twittjr using your own PCjr, assuming you have one.

Oh, and in case you're wondering why the logo is so dang huge: Twittjr was designed as an eye-catching device to attract visitors to the [Computer Science House](http://www.csh.rit.edu/) tables at [ImagineRIT](http://www.rit.edu/imagine/) 2009. Collapsing the logo into a textual form and using the additional space to display more tweets is left as an exercise for the reader.


What You'll Need
----------------

* One IBM PCjr with DOS boot disk and Cartridge BASIC cartridge
* One of the following:
  * Internal PCjr modem installed (limited to 300 baud)
  * External serial modem with PCjr serial adapter to attach it
* A 5.25-inch floppy drive in your own computer, to copy the program
* A spare 5.25-inch disk (or use your boot disk if it's writable)
* Any modern-ish PC to use as a server
* A modem for said PC that appears to your OS as a serial device
* A working installation of Ruby on said PC
* Two phone lines (at least one must be capable of calling the other)


The Instructions
----------------

1. Make sure both of your phone lines have dial tones and can call each other, then hook up your modems to their respective phone lines.

2. Edit twittjr.rb and change ModemDevice according to where your modem is on the server.

3. If you are using the PCjr internal modem, edit TWITTJR.BAS and change "COM1:1200" on line 100 to "COM2:300". Be sure to read the comments in there as well.

4. Boot your PCjr with Cartridge BASIC in a cartridge slot and your DOS disk in the drive.

5. Get TWITTJR.BAS onto a disk, and get that disk into your PCjr. Enter "basica twittjr.bas" at the DOS prompt. Provide an initial search term or just press Enter to use the default.

6. On the server machine, run twittjr.rb with your Ruby installation.

7. At this point, both the PCjr and the server should be asking you whether to use answer mode. Choose yes on one of them, then choose no on the other, and enter the appropriate phone number.

8. After some modem-y noises, your connection will hopefully be successful! If so, the server will report "Connected!", and the PCjr will draw out the Twittjr logo and start downloading tweets. Left to its own devices, it will refresh slightly more often than once a minute. Press F3 on the PCjr to enter a new search term. Press F10 on the PCjr, or Enter on the server, to close the connection.


It Didn't Work!
---------------

Yeah, good luck with that. Modem connections are finicky, and you're dealing with some *really* ancient hardware here (not to mention my code certainly isn't bulletproof). The first thing to try is to simply try again: I can't count the number of inexplicable failures I've had that seemingly "fixed themselves" on the next attempt. But other than that, there are a million ways for this setup to go wrong, and you'll need to know a thing or two about modems, serial ports, BASIC, and DOS to figure out what's what.

Do note the crucial requirement that your server's modem must appear as a serial device to your operating system. In other words, you must be able to access it directly by opening a terminal on /dev/ttySx or COMx. On Linux, use "screen /dev/ttySx" for this; on Windows, PuTTY has an option to open a serial connection. Try entering "AT" into your terminal, and if you get "OK" back, you're good (for more info, [see here](http://en.wikipedia.org/wiki/Hayes_command_set)). Be aware that 99% of internal PCI modems you will encounter are "softmodems" that require vendor-specific drivers to function, which you may not have if you're on Linux.

One last debugging tip: In the BASICA editor on your PCjr, entering "TERM" will load up a simple terminal applet you can use to talk to your modem. Note that this will replace your currently loaded program.
