README.linux for JDK 1.1.7, Version 1a
11/4/98

This is the Blackdown Java-Linux port of JDK 1.1.7 to Linux.
    - includes numerous bug fixes direct from Sun
    - additional bug fixes by the Blackdown Java-Linux Porting Team
    - fix for kernel accept() bug, caused slow Java Web Server
         - turn-off by: export JDK_NO_KERNEL_FIX=true

SPECIAL NOTE: Starting with 1.1.6v5, we are building with Metro Link's
"Motif Complete!" product, which was GENEROUSLY DONATED by Metro Link
to the Java-Linux porting team.  This was an amazingly generous
gesture from a commercial company in support of the Linux community.
The Java-Linux porting team is extremely grateful for Metro Link's
contribution to our work!

* This port was developed under Sun's non-commercial license agreement.

I (sbb) would like to say a special THANK YOU to all of the people who
took the time to respond to my survey about library versions.  Thanks
to your support, we now have a mechanism that automatically can deal
with all kinds of different versions of libraries on all kinds of
different Linux systems.

We hope you enjoy the numerous improvements available in JDK 117.  We
will continue to work to both improve the port and fix bugs.

Thanks,

Your Blackdown Java-Linux Porting Team
(Steve Byrne, Karl Asha, Johan Vos, Chris Seawood, Stephen Wynne,
Juergen Kreileder, Scott Hutinger, Michael Sinz, Stephen Zander, Kevin
Hendricks, Brad Crochet, and all the other people who have contributed
bug reports, tested builds, and helped the port...)


Reporting bugs
--------------
Please, *Please*, report all bugs to the Java-Linux jitterbug
bug database at http://www.blackdown.org/java-linux.html.

If you do report a bug, it helps to have the following
information:

* What Linux distribution (with version) you have (RedHat 5.0, Debian 1.3.1,
  etc.)
* Which version of the JDK you downloaded (including the "v" number,
  i.e. 1.1.5v7 or whatever)
* Which architecture you downloaded (libc, glibc, powerpc, sparc, etc.)

NOTE: This cannot be said enough:

   Sending (or making available via web or ftp) a small program that
   demonstrates the bug increases its chance of being diagnosed and fixed
   by two orders of magnitude.  I (and others) can zoom right in on what the
   problem is right away, and that's often more than 1/2 the battle to getting
   things fixed.

If the JDK crashes on startup, it's quite helpful to send the output of

   ldconfig -D

as this tells us a lot about what libraries you have on your system, and
variations in library versions are often the cause of crashes on startup.

NOTE: *IF* you're getting crashes on startup (typically SEGVs), you should try
removing or renaming the libc.so.* and libdl.so.* from the
<java>/lib/i386/green_threads/linuxlibs directory.  If that fixes your problem,
please report it using http://www.blackdown.org/java-linux.html, as this
indicates a failure in the checkVersion script.

If you have weird AWT behavior, it helps to know what window manager you are
using, and what version of X.  Typically it doesn't help to know what
display adapter you have.

Sanity testing of your code on Solaris (to see if it breaks there) is always
encouraged, as this often rules out generic JDK bugs (and, heaven forbid, bugs
in your code that you didn't realize you had :-).  Win32 sanity checking is
also good, but since the Linux JDK is derived by modifying the Solaris version,
Win32 is not nearly as representative in most cases.

If you can't come up with a small program that reproduces the bug, but it
occurs in some standard application that's downloadable off the web, please
include the URL to get to the application -- this saves us the effort (and
possibly differing results) of finding the program ourselves.  Having exact
instructions about how to reproduce the problem ("Start ICQ via 'java icq'.
Select the destroy->empire menu.  Click the ok button and then click on the
Bill Gates icon. ..." helps a lot).

If you get out of memory errors, having information about how much RAM and swap
space you have is quite useful.  It is essential that you verify that you have
as much swap as you think by using the top program.  I've had cases where I was
sure that I had enough swap and was getting out of memory errors, only to find
that I'd forgotten to turn a particular swap file back on.  Also, if you're
invoking the java interpreter with any parameters which affect memory size
(like mx), we need to know that too.


Missing libXp
--------------

The JDK now depends on having the X printing library, libXp installed with the
rest of your X files.  This is part of the most recent X11 distributions, so
you'll need to upgrade (or, if you are daring, you can just extract the
libXp.so* file from the upgrade package for your Linux distribution and
install it by hand w/o upgrading everything else, although this is unlikely to
work if your X libraries are substantially out of date)


Installation
------------

Installation of the Linux JDK is trivial, but you have to get the version of
the JDK that matches your environment.  (If you are not on an x86 based Linux
system, skip to the bottom of this section).  For the x86 processor
family, there are two flavors; the version you get depends on your environment.
The versions are known as "glibc" and "libc5", and reflect the type of C
runtime library that's installed on your machine.  Generally, you should get
the glibc version if your machine is running glibc, but libc5 should work
acceptably as well, if you have a recent (say, past April 1, 1998) version of
the glibc library installed on your machine (RedHat 5.0 by default comes with
an older version of glibc, you need to get the 2.0.7-7 version from RedHat to
win).

To discover which kind of system you have, (remember, these instructions
are for x86 based Linux only):

   ls -l /lib/libc.so.*

What you are looking for is lines of the form

   /lib/libc.so.<num>

If all you see are lines where <num> is 5, then you have libc5.  If you
have a line where <num> is 6, then you have glibc, and you should get the
glibc version.  An additional check is to look in /lib for libdl.so.<num>:
if at least one <num> here is 2, then you definitely have a glibc system and
you should get the glibc JDK (although I believe the libc version will also
work for you).

Now that that's out of the way, you're asking "Yes, Steve, that's all fine
and dandy, but how do I INSTALL the darn thing???".  It's *real* easy:

1) decide where you want the directory to live.  It can be anywhere in your
   filesystem that supports symbolic links (i.e. not on certain mounted
   Windows filesystems).
2) unzip and untar into your chosen directory (the system untars itself
   into a subdirectory called "jdk1.1.7"; you can call it whatever you like
   after you untar it -- I call mine "fred").  Want to know a secret?  GNU
   tar, like all winning GNU software, has a cool feature (ok, ok, it has
   more than just one) that few folks seem to know about: you can unzip
   and untar with one tar command!  Just do

       tar xvzf jdk1.1.7.tar.gz   # whatever the file is called

   the "z" flag says "gunzip before untarring".  The same flag works in
   reverse when tarring.  It's handy, and I think more people ought to
   know about it.
3) [optional] Put the bin directory of the JDK into your PATH environment
   variable so you can just say "java" instead of "/foo/bar/jdk1.1.7/bin/java"
   when you want to run the interpreter.  For my setup, I'd do (bash shell,
   I'm sure you are bright enough to figure out the csh equivalent):

      export PATH=/fred/bin:$PATH # remember, I changed my jdk1.1.7 directory
				  # to be "fred"

That's it!  No CLASSPATH, no JAVA_HOME, or other environment variables to set
to get the basic system running.  It can be installed anywhere on your
machine, and it figures out whatever information it needs about where it was
installed automatically when it runs.



Java Virtual Machine variations
-------------------------------

There are three versions of the Java interpreter that are shipped with this
release.  The default one depends on having X libraries present on your system,
and has Motif statically linked in (so it does not require Motif to be
installed on your machine).  One other version has no dependency on X, and
starts up much faster, but it cannot be used with X, because there's no way to
have a shared library have a weak reference to another shared library with the
current ld.  The other other version dynamically references Motif, but will use
your version of Motif at runtime instead of the statically bound version.

The environment variables NS_JAVA and DYN_JAVA control the behavior.  If it's
NS_JAVA unset, or if it's set to a zero length value, you get the default,
statically linked Java interpreter.  If, however, you have NS_JAVA set to
"true" (or something non-zero length), you'll get the much smaller
nonstatically linked Java interpreter.  You will not be able to run any
AWT based applications with the nonstatically linked java interpreter, so only
set NS_JAVA for non-GUI based applications.  [For the curious: in the
bin/i586/green_threads/ directory, the executables (java for the static
version, and java_ns for the non-static version) are kept.  I make no promises
about keeping the name "java_ns" stable across releases; you should use the
"java" shell script in the jdk1.1.5/bin directory and not invoke the "java"
binary executable directly.]

Similarly, if the DYN_JAVA environment variable is set to a non-empty value,
the version of the Java interpreter that uses the Motif shared library on your
machine is selected.  This allows you to use your own local Motif shared
library instead of the statically bound one, so you can experiment with
LessTif, and can take advantages of more recent versions of Motif.

The environment variables described above also control the operation of the
"jre" program in the same manner.


Native Threads support
----------------------

Starting with the 1.1.7 v1a port of the Java Virtual Machine, we have
added native thread support.  Traditionally, the JVM used user based
threads, also known as "green" threads.  Native threads, on the other
hand, use the operating system to do the task switching.

Native threads are thus a benefit in multi-processor (SMP) systems
and they tend to make native method invocation support easier to
deal with.

Native threads do have some limitations relative to green threads.
They require more overhead and are limited to the number of processes
your Linux kernel supports.

Native thread support is new as of 1.1.7 v1a due to the wonderful
effort of Phill Edwards.

To install the native threads package, you need to first download
the JDK, JRE, RT and install that.  Next, you need to get the matching
native threads package and install that into the same location.
Finally, to use the native threads version of the JVM, you need
to set the THREADS_FLAG environment variable to "native"

Note, that while the native threads support works very well and has
been tested by the Java-Linux porting team, it should still be viewed
as "beta" code as it has not had the extended testing that the
green threads code has.

Also, at this time there is no native threads support for libc5 systems.
Only glibc based Linux systems.


Other issues
------------

Due to basic problems with the JDK 1.1.7 source base from Sun, interactions
with various window managers may be "interesting".  For fvwm, and for CDE
things work fine; for others, odd window placement or problems with sizing
occur.  We believe that we've fixed most of these as of the v5 release.  We
would welcome help in diagnosing and and fixing the problems on the various
window managers.

Resizing AWT components has been linked with memory corruption.  As of the
time of this writing, it appears that the corruption (double freeing) is
happening within Motif or Xt.  By default, this release does some
extra checking for this case and ignores duplicated free operations.
This has a very small overhead associated with it.  If you're not
doing AWT related Java programming, and you want to live dangerously,
set the DO_NOT_CHECK_MEM environment variable to some non-zero-length
value, and don't complain if the system gets less robust.

If you want to turn off memory freeing completely (like it was in Linux JDK
1.1.3), you can set the DO_NOT_FREE environment variable to some
non-zero-length value.  This most likely won't help the robustness of the JVM,
but if you are having random crashes, it's worth turning this on and seeing
if conditions improve.

Enjoy!



