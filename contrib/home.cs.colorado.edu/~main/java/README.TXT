PROGRAMMING LANGUAGES CD-ROM
Date: January 6, 1999
Directory: /java
Also available at: http://www.cs.colorado.edu/~main/java/
Installation notes are at the bottom of this file.

Description:
    Java(TM) Development Kit 1.2 for Windows
    Java(TM) Development Kit 1.1.7 for Linux

Authors:
    Sun Microsystems, Inc.
    Blackdown Java-Linux Porting Team
    (Steve Byrne, Karl Asha, Johan Vos, Chris Seawood, Stephen Wynne,
    Juergen Kreileder, Scott Hutinger, Michael Sinz, Stephen Zander, Kevin
    Hendricks, Brad Crochet, and all the other people who have contributed
    bug reports, tested builds, and helped the port...)
    S.H. Smith (unzip)
    
Original sources:
    http://java.sun.com/products/jdk/1.2/download-windows.html
    ftp://ce.usu.edu/pub/mirror/linux/JDK/
    ftp://ftp.cs.washington.edu/pub/ntemacs/latest/utilities/i386/ 

Files in this directory:
    README.TXT ---------------------- Description of directory
    README.html --------------------- HTML version of README.TXT
    jdk_1_1_7-v1a-glibc-x86_tar.gz -- Linux JDK with glibc libraries
    jdk_1_1_7-v1a-libc5-x86_tar.gz -- Linux JDK with libc5 libraries
    jdk12-doc.zip ------------------- JDK 1.2 Documentation
    license.txt --------------------- Sun Microsystem License
    readme-1_1_7v1a.txt ------------- Notes for the Linux JDK
    unzip.exe ----------------------- Windows unzipper

Additional files required:
    If you are running on a Windows platform, you may obtain a free
    copy of the Java(TM) Development Kit for Windows from 
    http://java.sun.com/products/jdk/1.2/download-windows.html
    The file you will obtain is approximately 17MB:

    jdk12-win32.exe ----------------- Java Development Kit 1.2 

    Sun's license agreement does not allow this version of JDK to
    be copied, except for your own use, so I can't include it here.
    However, many Java(TM) books come with a CD-ROM that does include
    the JDK for Windows. 

Help:
    Sun Microsystems JDK for Windows:
    http://java.sun.com/products/jdk/1.2/download-windows.html

    Overall documentation:
    http://java.sun.com/products/jdk/1.2/docs/index.html

    Installation of the JDK for Windows:
    http://java.sun.com/products/jdk/1.2/install-windows.html

    Installation of the JDK for Linux:
    The readme-1_1_7v1a.txt file in this directory

    Documentation installation:
    http://java.sun.com/products/jdk/1.2/install-docs.html
    
    Java(TM) Applications Programmers Interface Documentation:
       http://java.sun.com/products/jdk/1.2/docs/index.html
    or on the CD-ROM in:
       \manuals\java\index.html
    or if you installed on your Windows hard drive:
       \jdk1.2\docs\index.html

------------------------------------------------------------------------
My Installation Notes:
On my machines, here's how I installed the JDK 1.2:

1. For a Windows system, make a directory for your Java(TM)
   installation. I called my directory C:\language.
   You'll  need to put the following file in that directory:
      jdk12-win32.exe
   You can obtain this file from Sun's download site
   (http://java.sun.com/products/jdk/1.2/download-windows.html)
   or from CD-ROMs that come with some Java(TM) books. I couldn't
   include the file here because of licensing restrictions.
   Once the file is in place, go to that directory follow the
   installation directions from
   http://java.sun.com/products/jdk/1.2/install-windows.html.
   You'll end up with a subdirectory called jdk1.2 that contains
   the JDK installation.

2. For Linux systems, log on as the root user, and change to
   your installation directory (I used /usr/local/lib). Then find out
   which C runtime libraries are installed on your machine. You can
   do this with the command
      ls -l /lib/libc.so.*
   What you are looking for is lines of the form /lib/libc.so.<num>
   If all you see are lines where <num> is 5, then you have libc5, 
   and you should copy jdk_1_1_7-v1a-libc5-x86_tar.gz to your 
   installation directory. If you have a line where <num> is 6, then
   you have glibc and you should copy jdk_1_1_7-v1a-glibc-x86_tar.gz
   to your installation directory. Then run these commands:
      tar -xzvf jdk_1_1_7-v1a-*-x86_tar.gz
      rm jdk_1_1_7-v1a*x86_tar.gz
      ln -s jdk117_v1a java
   This installation puts the java executables in the directory
   /usr/local/lib/java/bin, so I would suggest that you then add this
   directory to your path.

3. To install all of the JDK documentation on your hard drive,
   Windows users can copy jdk12-doc.zip to the directory that
   already has jdk1.2 as a subdirectory (in my case, this was the
   C:\language directory). Also copy unzip.exe to this directory
   and then execute: 
      unzip jdk1.2

----------------------------------------------------------------------------
