# Twittjr

Twittjr is a system that displays a pseudo-live feed of the most recent public tweets for any given search... on an [IBM PCjr](http://en.wikipedia.org/wiki/IBM_PCjr).

[<img width="430" src="https://cloud.githubusercontent.com/assets/394835/18921252/132faf74-8572-11e6-83ef-2b826a050ada.jpg">](https://cloud.githubusercontent.com/assets/394835/18921252/132faf74-8572-11e6-83ef-2b826a050ada.jpg) [<img width="430" src="https://cloud.githubusercontent.com/assets/394835/18921411/ad79a4b8-8572-11e6-99b7-1fb2ebfdbfc4.jpg">](https://cloud.githubusercontent.com/assets/394835/18921411/ad79a4b8-8572-11e6-99b7-1fb2ebfdbfc4.jpg)

## Background

In my second year at RIT I discovered a fully-functional IBM PCjr gathering dust on a shelf in the Computer Science House server room. Noticing it had a variant of BASIC, one of the first languages I ever learned, I thought I'd write an eye-catching program that would attract people to our tables at [ImagineRIT](http://www.rit.edu/imagine/) 2009. Lots of CSHers had been joining Twitter recently, and someone who saw me fiddling with the PCjr jokingly suggested putting Twitter on it. So I did!

## How it works

You have a PCjr hooked up to an external dial-up modem, which is connected to a phone line. Elsewhere, you have a modern internet-connected computer with another dial-up modem, connected to another phone line. The PCjr dials this "server" and establishes a modem connection, which it uses to send a request for whatever search term the user enters. The server uses the Twitter Search API to download the three most recent posts on the public timeline that match the search, and sends them back over the phone line to the PCjr, which displays them on the screen in glorious 16-color ASCII-vision. In the absence of user interaction, the PCjr refreshes the search results every minute or so, providing a "live" feed.

## How to set it up

You will need:

* IBM PCjr with:
  * PC DOS 2.10 boot disk
  * Cartridge BASIC cartridge
  * External serial modem with PCjr serial adapter to attach it
    * Internal modem might work, but is limited to 300 baud
* Server PC with:
  * Ruby 1.8 (newer versions don't work due to string encoding differences)
  * Modem that appears to your OS as a serial device
* Two phone lines, one of which is capable of calling the other
* Some way to transfer the Twittjr code to your PCjr (probably via floppy disk)

Now do this:

1. Make sure both of your phone lines have dial tones and one can call the other, then hook up your modems.
2. Place twittjr.rb on your server and ensure `ModemDevice` is correct.
3. Place TWITTJR.BAS on your PCjr. If using the internal modem, change `COM1:1200` on line 100 to `COM2:300`. Read the comments for additional tweaks that might be necessary.
4. Boot your PCjr with Cartridge BASIC in a cartridge slot and PC DOS disk in the drive.
5. On the PCjr, run `basica twittjr.bas`. Provide an initial search term or press Enter for the default.
6. On the server, run `ruby twittjr.rb`.
7. Both the PCjr and the server should be asking whether to use answer mode. Choose yes on one of them, then choose no on the other and enter the appropriate phone number.
8. Modem noises will occur. If the connection is successful, the server will report "Connected!"
9. The PCjr will auto-refresh the search results about once a minute. Press **F3** on the PCjr to enter a new search term. Press **F10** on the PCjr, or Enter on the server, to close the connection.

## Troubleshooting

This setup is not completely reliable, so the first thing to try is to "try, try again". I've had quite a number of inexplicable failures that seemingly fixed themselves on the next attempt.

Note the requirement that your server's modem must be accessible as a serial device. On Linux, you can test this with `screen /dev/ttySx`. On Windows, PuTTY has an option to open a serial connection. Keep in mind the vast majority of internal PCI modems are "softmodems" that require vendor-specific drivers to function, which may only exist on Windows.

In the BASICA editor on your PCjr, entering `TERM` on a new line will load a simple terminal applet you can use to send modem commands. Note this will replace your currently loaded program.

The basic modem command `AT` should return `OK` if your modem is working correctly. [See here for additional commands](https://en.wikipedia.org/wiki/Hayes_command_set#The_basic_Hayes_command_set).
