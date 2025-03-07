------------------------------------------------------------------------
PBATS 3.2   Horst's Batch Tools           (c) 1994..2002 Horst Schaeffer
------------------------------------------------------------------------
                               Note: The name of the archive was changed
                                     to match the German version.

These batch tools were spread through the FIDOnet - back in the days
when many computer users were still familiar with good old DOS..

But batch files still may be usefull even under Windows: when you just
want to make a quick script, when you run games in DOS mode, or when
you want to make boot disk handling.

For this release only some text files were edited, and a few tools were
enhanced as requested by users. The ANSI stuff is removed.

Please note: Programs that set environmental variables directly (in the
COMMAND.COM environment) will not function under Windows NT/2000/XP.
See notes in TXT files.

New tools (that are mostly W2K compatible) can be found on my homepage:

        http://home.mnet-online.de/horst.muc

All programs are accompanied by a TXT file.
A brief help is available with /? (except NSET).

Contents of this package ---------------------------------------------

Variables, Output Handling

NSET     2.1    pipe data from STDIN into an environmental variable
LISTMOD  2.3    make list of commands from input list
LOGECHO  2.1    custom entries for logfiles, with enhanced date handling
QECHO    1.3    "quote echo" with control codes, defaults without CR/LF
COUNT    1.0    Count, add, subtract (variable), fixed length option
FPATH    1.1    locate path of program file, optional CHDIR
RANDOM   1.1    random number (given range) to STDOUT

Batch Control

EVERY    1.0    run jobs once a day / on specified days of week
DREADY   2.2    disk(ette) ready?, optional check "ready to write"?
PCHECK   1.1    checks if (parallel) printer is ready, optional reset
ESPACE   1.2    environment variable space report/check with errorlevel
KPUSH    2.0    stuff keystrokes into keyboard buffer, code test mode
CHOIX    1.1    CHOICE clone with mouse support
INPUT    1.2    string input, editing of existing variable..
ISDATE   2.3    compare date (also file date, today)
TIMENOW  1.0    current time within given period(s)?
WAIT     1.4    wait with prompt, key by errorlevel
WHAT     1.0    by errorlevel: hour/minute/year/month/day/day of week

File Utilities

CRLF     1.3    convert: lines to be terminated by CR+LF, CR or LF
LINEX    1.2    extract [multiple] range of lines from ASCII file
DELAGE   1.3    delete/report files by age (days)
CRC32    2.1    report and check CRC32, optional list processing
LOGTRIM  1.7    trim logfiles (min/max KB)

Effects

BANNER   1.2    big font looping message
BIGFONT  1.0    display big characters (4 lines high), round pixels
CSOUND   2.2    sound output to PC speaker / resident beep replacement
WAIT4    1.4    wait for/until with large "digital clock", options

Other

PACO     1.2    executable COM file archive (run with prefix)

------------------------------------------------------------------------

Copyright

These utilities are distributed as "freeware," that is, they are free
programs with copyright reserved by the author, Horst Schaeffer. There
is no restriction on their use within private corporations, nor on their
use in governmental agencies. There are no warranties of any kind, nor
any liability by the author.  Users accept full responsibility for the
use they make of the software and for any damage caused thereby.

------------------------------------------------------------------------

Credits

Thanks to Robert Bull and Douglas Myers for testing and contributions
to program features and TXT files, and of course to the BATPOWER and
BATCH.GER people who reported bugs or supplied input for enhancements.

------------------------------------------------------------------------

Contact: Horst Schaeffer
         eMail:    horst.schaeffer@gmx.net
         Homepage: http://home.mnet-online.de/horst.muc

------------------------------------------------------------------------
= 09 AUG 2002
