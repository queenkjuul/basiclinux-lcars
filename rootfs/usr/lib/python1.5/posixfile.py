#
# Start of posixfile.py
#

#
# Extended file operations
#
# f = posixfile.open(filename, [mode, [bufsize]])
#       will create a new posixfile object
#
# f = posixfile.fileopen(fileobject)
#       will create a posixfile object from a builtin file object
#
# f.file()
#       will return the original builtin file object
#
# f.dup()
#       will return a new file object based on a new filedescriptor
#
# f.dup2(fd)
#       will return a new file object based on the given filedescriptor
#
# f.flags(mode)
#       will turn on the associated flag (merge)
#       mode can contain the following characters:
#
#   (character representing a flag)
#       a       append only flag
#       c       close on exec flag
#       n       no delay flag
#       s       synchronization flag
#   (modifiers)
#       !       turn flags 'off' instead of default 'on'
#       =       copy flags 'as is' instead of default 'merge'
#       ?       return a string in which the characters represent the flags
#               that are set
#
#       note: - the '!' and '=' modifiers are mutually exclusive.
#             - the '?' modifier will return the status of the flags after they
#               have been changed by other characters in the mode string
#
# f.lock(mode [, len [, start [, whence]]])
#       will (un)lock a region
#       mode can contain the following characters:
#
#   (character representing type of lock)
#       u       unlock
#       r       read lock
#       w       write lock
#   (modifiers)
#       |       wait until the lock can be granted
#       ?       return the first lock conflicting with the requested lock
#               or 'None' if there is no conflict. The lock returned is in the
#               format (mode, len, start, whence, pid) where mode is a
#               character representing the type of lock ('r' or 'w')
#
#       note: - the '?' modifier prevents a region from being locked; it is
#               query only
#

class _posixfile_:
    states = ['open', 'closed']

    #
    # Internal routines
    #
    def __repr__(self):
        file = self._file_
        return "<%s posixfile '%s', mode '%s' at %s>" % \
                (self.states[file.closed], file.name, file.mode, \
                 hex(id(self))[2:])

    def __del__(self):
        self._file_.close()

    #
    # Initialization routines
    #
    def open(self, name, mode='r', bufsize=-1):
        import __builtin__
        return self.fileopen(__builtin__.open(name, mode, bufsize))

    def fileopen(self, file):
        if `type(file)` != "<type 'file'>":
            raise TypeError, 'posixfile.fileopen() arg must be file object'
        self._file_  = file
        # Copy basic file methods
        for method in file.__methods__:
            setattr(self, method, getattr(file, method))
        return self

    #
    # New methods
    #
    def file(self):
        return self._file_

    def dup(self):
        import posix

        try: ignore = posix.fdopen
        except: raise AttributeError, 'dup() method unavailable'

        return posix.fdopen(posix.dup(self._file_.fileno()), self._file_.mode)

    def dup2(self, fd):
        import posix

        try: ignore = posix.fdopen
        except: raise AttributeError, 'dup() method unavailable'

        posix.dup2(self._file_.fileno(), fd)
        return posix.fdopen(fd, self._file_.mode)

    def flags(self, *which):
        import fcntl, FCNTL

        if which:
            if len(which) > 1:
                raise TypeError, 'Too many arguments'
            which = which[0]
        else: which = '?'

        l_flags = 0
        if 'n' in which: l_flags = l_flags | FCNTL.O_NDELAY
        if 'a' in which: l_flags = l_flags | FCNTL.O_APPEND
        if 's' in which: l_flags = l_flags | FCNTL.O_SYNC

        file = self._file_

        if '=' not in which:
            cur_fl = fcntl.fcntl(file.fileno(), FCNTL.F_GETFL, 0)
            if '!' in which: l_flags = cur_fl & ~ l_flags
            else: l_flags = cur_fl | l_flags

        l_flags = fcntl.fcntl(file.fileno(), FCNTL.F_SETFL, l_flags)

        if 'c' in which:        
            arg = ('!' not in which)    # 0 is don't, 1 is do close on exec
            l_flags = fcntl.fcntl(file.fileno(), FCNTL.F_SETFD, arg)

        if '?' in which:
            which = ''                  # Return current flags
            l_flags = fcntl.fcntl(file.fileno(), FCNTL.F_GETFL, 0)
            if FCNTL.O_APPEND & l_flags: which = which + 'a'
            if fcntl.fcntl(file.fileno(), FCNTL.F_GETFD, 0) & 1:
                which = which + 'c'
            if FCNTL.O_NDELAY & l_flags: which = which + 'n'
            if FCNTL.O_SYNC & l_flags: which = which + 's'
            return which
        
    def lock(self, how, *args):
        import struct, fcntl, FCNTL

        if 'w' in how: l_type = FCNTL.F_WRLCK
        elif 'r' in how: l_type = FCNTL.F_RDLCK
        elif 'u' in how: l_type = FCNTL.F_UNLCK
        else: raise TypeError, 'no type of lock specified'

        if '|' in how: cmd = FCNTL.F_SETLKW
        elif '?' in how: cmd = FCNTL.F_GETLK
        else: cmd = FCNTL.F_SETLK

        l_whence = 0
        l_start = 0
        l_len = 0

        if len(args) == 1:
            l_len = args[0]
        elif len(args) == 2:
            l_len, l_start = args
        elif len(args) == 3:
            l_len, l_start, l_whence = args
        elif len(args) > 3:
            raise TypeError, 'too many arguments'

        # Hack by davem@magnet.com to get locking to go on freebsd;
        # additions for AIX by Vladimir.Marangozov@imag.fr
        import sys, os
        if sys.platform in ('netbsd1', 'freebsd2', 'freebsd3'):
            flock = struct.pack('lxxxxlxxxxlhh', \
                  l_start, l_len, os.getpid(), l_type, l_whence) 
        elif sys.platform in ['aix3', 'aix4']:
            flock = struct.pack('hhlllii', \
                  l_type, l_whence, l_start, l_len, 0, 0, 0)
        else:
            flock = struct.pack('hhllhh', \
                  l_type, l_whence, l_start, l_len, 0, 0)

        flock = fcntl.fcntl(self._file_.fileno(), cmd, flock)

        if '?' in how:
            if sys.platform in ('netbsd1', 'freebsd2', 'freebsd3'):
                l_start, l_len, l_pid, l_type, l_whence = \
                    struct.unpack('lxxxxlxxxxlhh', flock)
            elif sys.platform in ['aix3', 'aix4']:
                l_type, l_whence, l_start, l_len, l_sysid, l_pid, l_vfs = \
                    struct.unpack('hhlllii', flock)
            elif sys.platform == "linux2":
                l_type, l_whence, l_start, l_len, l_pid, l_sysid = \
                    struct.unpack('hhllhh', flock)
            else:
                l_type, l_whence, l_start, l_len, l_sysid, l_pid = \
                    struct.unpack('hhllhh', flock)

            if l_type != FCNTL.F_UNLCK:
                if l_type == FCNTL.F_RDLCK:
                    return 'r', l_len, l_start, l_whence, l_pid
                else:
                    return 'w', l_len, l_start, l_whence, l_pid

#
# Public routine to obtain a posixfile object
#
def open(name, mode='r', bufsize=-1):
    return _posixfile_().open(name, mode, bufsize)

def fileopen(file):
    return _posixfile_().fileopen(file)

#
# Constants
#
SEEK_SET = 0
SEEK_CUR = 1
SEEK_END = 2

#
# End of posixfile.py
#
