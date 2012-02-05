1'
2' Twittjr Client Application
3' Setup instructions: https://github.com/grantovich/Twittjr
4' Project details: http://grantovich.net/projects/twittjr/
5'
1' WARNING: All line breaks in this file must be DOS-style CR+LFs in order
1' to load correctly on a PCjr. You may need to convert line breaks if you
1' modify this file in a Linux or Unix-based environment.
1'

10 ON ERROR GOTO 666
11 DEFINT A-Z: KEY OFF: WIDTH 80: CLS
12 CLEARED = 1   ' "Display already cleared" flag for the refresh routine
13 CONNECTED = 0 ' Flag to indicate a connection has been established
14 LASTPOST = 0  ' Tells how many posts were returned by the last update
15 BUFFER$ = ""  ' Stores not-yet-processed data coming in from the modem
16 MSG$ = ""     ' The last message returned from processing the buffer
17 SEARCH$ = ""  ' The current search term
18 ' Stores data on the Twitter posts currently being displayed
19 DIM POSTS$(3,3): IDXAUTHOR = 1: IDXTEXT = 2: IDXTIME = 3
20 ' Parameters and return value storage for the word-wrapping routine
21 WRAPME$ = "": WRAPTO = 0: WRAP1$ = "": WRAP2$ = "":

1'  === Program init sequence
1'  Note: You may need to change lines 100, 110, 170, and 180 to fit your
1'  modem. In particular, S37=9 is a hack specific to my setup that you
1'  probably won't even need. However, make sure you leave the E0 in there,
1'  or it will cause problems with the buffer processing.
1'

100 OPEN "COM1:1200,N,8,1" AS #1
110 PRINT #1, "AT E0 S7=25"
120 LINE INPUT "Enter initial search string: "; SEARCH$
130 IF SEARCH$ = "" THEN SEARCH$ = "twitter"
140 LINE INPUT "Use answer mode (y/n)? "; ANS$
150 IF ANS$ <> "y" THEN LINE INPUT "Number to dial: "; DIAL$
160 IF ANS$ = "y" THEN GOTO 170 ELSE GOTO 180
170 PRINT #1, "AT S0=1": PRINT "Waiting for connection, press F10 to abort...": GOTO 200
180 PRINT #1, "AT S37=9 DT"+DIAL$: PRINT "Dialing, press F10 to abort..."
190 ON TIMER(30) GOSUB 8000: TIMER ON
200 ON KEY(10) GOSUB 8500: KEY(10) ON
210 ON COM(1) GOSUB 1000: COM(1) ON
500 WHILE 1: WEND

666 ' === Error handling
670 IF ERR = 57 THEN RESUME
680 ON ERROR GOTO 0
690 END

1000 ' === COM activity subroutine
1010 IF LOC(1) > 0 THEN BUFFER$ = BUFFER$ + INPUT$(LOC(1), #1)
1020 WHILE INSTR(BUFFER$, CHR$(10))
1030   MSG$ = "": GOSUB 4000
1040   IF INSTR(MSG$, "CONNECT") THEN GOSUB 2000
1050   IF CONNECTED AND INSTR(MSG$, "NO CARRIER") THEN GOSUB 2100
1060   IF INSTR(MSG$, "TPOST") THEN GOSUB 3000
1070   IF INSTR(MSG$, "TDONE") THEN GOSUB 3500
1090 WEND
1100 RETURN

2000 ' ^^^ COM routine detected a CONNECT from the modem
2010 PRINT "Connected!": CONNECTED = 1
2020 CLS: GOSUB 9000: GOSUB 2900
2030 ON TIMER(45) GOSUB 2900
2040 ON KEY(3) GOSUB 2800: KEY(3) ON
2050 RETURN

2100 ' ^^^ COM routine detected a NO CARRIER from the modem
2110 PRINT "Connection lost (no carrier)"
2120 GOSUB 8500

2800 ' === Ask user for new search term (triggered by F3 keypress)
2810 TIMER OFF: LOCATE 12, 1: PRINT SPACE$(79);: LOCATE 12, 1
2820 LINE INPUT "Enter new search string: "; SEARCH$
2830 IF SEARCH$ = "" THEN GOTO 2800
2840 LOCATE 12, 1: PRINT SPACE$(79);: LOCATE 12, 1
2850 PRINT "Current search: ";: COLOR 15: PRINT SEARCH$;: COLOR 7

2900 ' === Send request for search term (triggered by 45-second timer)
2910 KEY(3) OFF: LASTPOST = 0
2920 LOCATE 12, 1: PRINT "Current search: ";: COLOR 15: PRINT SEARCH$;: COLOR 7
2930 COLOR 31: LOCATE 25, 1: PRINT "Loading...";: COLOR 7: LOCATE 12, 1
2940 PRINT #1, "TSEARCH" + CHR$(254) + SEARCH$
2950 TIMER ON: RETURN

3000 ' === Parse out a Twitter post stored in MSG$
3010 GOSUB 3100: PNUM = VAL(TOKEN$): LASTPOST = PNUM
3020 GOSUB 3100: POSTS$(PNUM, IDXAUTHOR) = TOKEN$
3030 GOSUB 3100: POSTS$(PNUM, IDXTEXT) = TOKEN$
3040 GOSUB 3100: POSTS$(PNUM, IDXTIME) = TOKEN$
3050 RETURN

3100 ' ^^^ Tear off the next CHR$(254)-delimited token from MSG$
3110 MSG$ = RIGHT$(MSG$, LEN(MSG$) - INSTR(MSG$, CHR$(254)))
3120 IF INSTR(MSG$, CHR$(254)) THEN TOKEN$ = LEFT$(MSG$, INSTR(MSG$, CHR$(254)) - 1) ELSE TOKEN$ = MSG$
3130 RETURN

3500 ' === Refresh display of stored Twitter posts
3510 LOCATE 14, 1: IF CLEARED = 0 THEN PRINT STRING$(109, 9) + SPACE$(7);
3520 IF LASTPOST = 0 THEN GOTO 3900
3530 PLAY "ML T120 O2 L32 C<C>D<D>E<E>F<F>G<G>"
3540 FOR P = 1 TO LASTPOST
3550   LOCATE 10+(P*4), 1: COLOR 11
3560   SPCINDEX = INSTR(POSTS$(P, IDXAUTHOR), " ")
3570   PRINT LEFT$(POSTS$(P, IDXAUTHOR), SPCINDEX - 1)
3580   WRAPME$ = RIGHT$(POSTS$(P, IDXAUTHOR), LEN(POSTS$(P, IDXAUTHOR)) - SPCINDEX)
3590   WRAPTO = 18: GOSUB 5000
3600   PRINT WRAP1$: PRINT WRAP2$;
3610   LOCATE 10+(P*4), 20: COLOR 7
3620   WRAPME$ = POSTS$(P, IDXTEXT): WRAPTO = 60: GOSUB 5000
3635   PRINT WRAP1$: LOCATE 10+(P*4)+1, 20
3640   IF WRAP2$ = "" THEN GOTO 3700
3650   WRAPME$ = WRAP2$: WRAPTO = 60: GOSUB 5000
3660   PRINT WRAP1$: LOCATE 10+(P*4)+2, 20
3670   IF WRAP2$ = "" THEN GOTO 3700
3680   IF LEN(WRAP2$) > 59-LEN(POSTS$(P, IDXTIME)) THEN WRAP2$ = LEFT$(WRAP2$, 56-LEN(POSTS$(P, IDXTIME))) + "..."
3690   PRINT WRAP2$ + " ";
3700   COLOR 8: PRINT POSTS$(P, IDXTIME);: COLOR 7
3710 NEXT P
3800 LOCATE 25, 1: PRINT SPACE$(10);: LOCATE 12, 1
3810 CLEARED = 0: KEY(3) ON
3820 RETURN
3900 ' Oops, no posts to display
3910 LOCATE 14, 3: PRINT "No results were returned!": LOCATE 12, 1
3920 GOTO 3800

4000 ' === Clean up the buffer and return the next complete message
4010 WHILE LEFT$(BUFFER$, 1) = CHR$(13) OR LEFT$(BUFFER$, 1) = CHR$(10)
4020   BUFFER$ = RIGHT$(BUFFER$, LEN(BUFFER$)-1)
4030 WEND
4040 IF LEN(BUFFER$) = 0 OR INSTR(BUFFER$, CHR$(10)) = 0 THEN RETURN
4050 MSG$ = LEFT$(BUFFER$, INSTR(BUFFER$, CHR$(13))-1)
4060 BUFFER$ = RIGHT$(BUFFER$, LEN(BUFFER$)-INSTR(BUFFER$, CHR$(10))+1)
4070 RETURN

5000 ' === Word-wrapping subroutine
5010 IF LEN(WRAPME$) > WRAPTO THEN GOTO 5050
5020 WRAP1$ = WRAPME$
5030 WRAP2$ = ""
5040 RETURN
5050 IF INSTR(LEFT$(WRAPME$, WRAPTO+1), " ") THEN GOTO 5090
5060 WRAP1$ = LEFT$(WRAPME$, WRAPTO)
5070 WRAP2$ = RIGHT$(WRAPME$, LEN(WRAPME$)-WRAPTO)
5080 RETURN
5090 IF MID$(WRAPME$, WRAPTO+1, 1) <> " " THEN GOTO 5200
5100 WRAP1$ = LEFT$(WRAPME$, WRAPTO)
5110 WRAP2$ = RIGHT$(WRAPME$, LEN(WRAPME$)-WRAPTO-1)
5120 RETURN
5200 SPC = WRAPTO
5210 WHILE MID$(WRAPME$, SPC, 1) <> " ": SPC = SPC-1: WEND
5220 WRAP1$ = LEFT$(WRAPME$, SPC)
5230 WRAP2$ = RIGHT$(WRAPME$, LEN(WRAPME$)-SPC)
5240 RETURN

8000 ' === Connection timeout routine (triggered by 30-second timer)
8010 IF CONNECTED THEN RETURN
8020 PRINT "Connection timed out!"

8500 ' === Connection hangup / program exit routine
8510 COM(1) OFF: PRINT #1, "+++";
8520 FOR I = 1 TO 1000: NEXT I
8530 PRINT #1, "ATHZ": CLOSE #1
8540 KEY ON: CLS: END

9000 ' === Subroutine to draw the Twittjr logo
9005 RESTORE 10000
9010 WHILE 1
9020   READ C
9030   IF C = 32 THEN GOTO 9200
9040   IF C = 33 THEN GOTO 9300
9050   COLOR C
9060   READ N
9070   PRINT STRING$(N, 219);
9080 WEND
9200 PRINT
9210 GOTO 9020
9300 COLOR 7
9310 PRINT STRING$(80, 205);
9320 RETURN

10000 ' ^^^ Logo data
10010 DATA 11,4,0,63,7,2,32
10020 DATA 11,4,0,26,11,4,0,2,11,4,0,6,11,4,32
10030 DATA 11,4,0,26,11,4,0,2,11,4,0,6,11,4,0,14,7,4,0,1,7,3,0,1,7,5,32
10040 DATA 11,10,0,26,11,4,0,6,11,4,0,16,7,2,0,2,7,3,0,4,7,2,32
10050 DATA 11,10,0,2,11,4,0,8,11,4,0,2,11,4,0,2,11,8,0,2,11,8,0,10,7,2,0,3,7,2,32
10060 DATA 11,4,0,8,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,2,11,8,0,2,11,8,0,10,7,2,0,2,7,2,32
10070 DATA 11,4,0,8,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,6,11,4,0,13,7,2,0,2,7,2,32
10080 DATA 11,4,0,8,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,6,11,4,0,13,7,2,0,2,32
10090 DATA 11,10,0,2,11,4,0,2,11,4,0,2,11,4,0,2,11,4,0,2,11,8,0,2,11,8,0,3,7,2,0,3,7,2,32
10100 DATA 0,2,11,8,0,4,11,12,0,4,11,4,0,4,11,6,0,4,11,6,0,4,7,5,32
10110 DATA 33
