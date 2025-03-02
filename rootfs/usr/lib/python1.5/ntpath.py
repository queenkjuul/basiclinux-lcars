# Module 'ntpath' -- common operations on WinNT/Win95 pathnames
"""Common pathname manipulations, WindowsNT/95 version. 
Instead of importing this module
directly, import os and refer to this module as os.path.
"""

import os
import stat
import string


# Normalize the case of a pathname and map slashes to backslashes.
# Other normalizations (such as optimizing '../' away) are not done
# (this is done by normpath).

def normcase(s):
    """Normalize case of pathname.

    Makes all characters lowercase and all slashes into backslashes.

    """
    return string.lower(string.replace(s, "/", "\\"))


# Return wheter a path is absolute.
# Trivial in Posix, harder on the Mac or MS-DOS.
# For DOS it is absolute if it starts with a slash or backslash (current
# volume), or if a pathname after the volume letter and colon starts with
# a slash or backslash.

def isabs(s):
    """Test whether a path is absolute"""
    s = splitdrive(s)[1]
    return s != '' and s[:1] in '/\\'


# Join two (or more) paths.

def join(a, *p):
    """Join two or more pathname components, inserting "\\" as needed"""
    path = a
    for b in p:
        if isabs(b):
            path = b
        elif path == '' or path[-1:] in '/\\':
            path = path + b
        else:
            path = path + os.sep + b
    return path


# Split a path in a drive specification (a drive letter followed by a
# colon) and the path specification.
# It is always true that drivespec + pathspec == p
def splitdrive(p):
    """Split a pathname into drive and path specifiers. Returns a 2-tuple
"(drive,path)";  either part may be empty"""
    if p[1:2] == ':':
        return p[0:2], p[2:]
    return '', p


# Split a path in head (everything up to the last '/') and tail (the
# rest).  If the original path ends in '/' but is not the root, this
# '/' is stripped.  After the trailing '/' is stripped, the invariant
# join(head, tail) == p holds.
# The resulting head won't end in '/' unless it is the root.

def split(p):
    """Split a pathname.  Returns tuple "(head, tail)" where "tail" is 
everything after the final slash.  Either part may be empty"""
    d, p = splitdrive(p)
    slashes = ''
    while p and p[-1:] in '/\\':
        slashes = slashes + p[-1]
        p = p[:-1]
    if p == '':
        p = p + slashes
    head, tail = '', ''
    for c in p:
        tail = tail + c
        if c in '/\\':
            head, tail = head + tail, ''
    slashes = ''
    while head and head[-1:] in '/\\':
        slashes = slashes + head[-1]
        head = head[:-1]
    if head == '':
        head = head + slashes
    return d + head, tail


# Split a path in root and extension.
# The extension is everything starting at the last dot in the last
# pathname component; the root is everything before that.
# It is always true that root + ext == p.

def splitext(p):
    """Split the extension from a pathname.  Extension is everything from the
last dot to the end.  Returns "(root, ext)", either part may be empty"""
    root, ext = '', ''
    for c in p:
        if c in ['/','\\']:
            root, ext = root + ext + c, ''
        elif c == '.':
            if ext:
                root, ext = root + ext, c
            else:
                ext = c
        elif ext:
            ext = ext + c
        else:
            root = root + c
    return root, ext


# Return the tail (basename) part of a path.

def basename(p):
    """Returns the final component of a pathname"""
    return split(p)[1]


# Return the head (dirname) part of a path.

def dirname(p):
    """Returns the directory component of a pathname"""
    return split(p)[0]


# Return the longest prefix of all list elements.

def commonprefix(m):
    "Given a list of pathnames, returns the longest common leading component"
    if not m: return ''
    prefix = m[0]
    for item in m:
        for i in range(len(prefix)):
            if prefix[:i+1] <> item[:i+1]:
                prefix = prefix[:i]
                if i == 0: return ''
                break
    return prefix


# Is a path a symbolic link?
# This will always return false on systems where posix.lstat doesn't exist.

def islink(path):
    """Test for symbolic link.  On WindowsNT/95 always returns false"""
    return 0


# Does a path exist?
# This is false for dangling symbolic links.

def exists(path):
    """Test whether a path exists"""
    try:
        st = os.stat(path)
    except os.error:
        return 0
    return 1


# Is a path a dos directory?
# This follows symbolic links, so both islink() and isdir() can be true
# for the same path.

def isdir(path):
    """Test whether a path is a directory"""
    try:
        st = os.stat(path)
    except os.error:
        return 0
    return stat.S_ISDIR(st[stat.ST_MODE])


# Is a path a regular file?
# This follows symbolic links, so both islink() and isdir() can be true
# for the same path.

def isfile(path):
    """Test whether a path is a regular file"""
    try:
        st = os.stat(path)
    except os.error:
        return 0
    return stat.S_ISREG(st[stat.ST_MODE])


# Are two filenames really pointing to the same file?

def samefile(f1, f2):
    """Test whether two pathnames reference the same actual file"""
    s1 = os.stat(f1)
    s2 = os.stat(f2)
    return samestat(s1, s2)


# Are two open files really referencing the same file?
# (Not necessarily the same file descriptor!)
# XXX THIS IS BROKEN UNDER DOS! ST_INO seems to indicate number of reads?

def sameopenfile(fp1, fp2):
    """Test whether two open file objects reference the same file (may not
work correctly)"""
    s1 = os.fstat(fp1.fileno())
    s2 = os.fstat(fp2.fileno())
    return samestat(s1, s2)


# Are two stat buffers (obtained from stat, fstat or lstat)
# describing the same file?

def samestat(s1, s2):
    """Test whether two stat buffers reference the same file"""
    return s1[stat.ST_INO] == s2[stat.ST_INO] and \
           s1[stat.ST_DEV] == s2[stat.ST_DEV]


# Is a path a mount point?
# XXX This degenerates in: 'is this the root?' on DOS

def ismount(path):
    """Test whether a path is a mount point (defined as root of drive)"""
    p = splitdrive(path)[1]
    return len(p)==1 and p[0] in '/\\'


# Directory tree walk.
# For each directory under top (including top itself, but excluding
# '.' and '..'), func(arg, dirname, filenames) is called, where
# dirname is the name of the directory and filenames is the list
# files files (and subdirectories etc.) in the directory.
# The func may modify the filenames list, to implement a filter,
# or to impose a different order of visiting.

def walk(top, func, arg):
    """walk(top,func,args) calls func(arg, d, files) for each directory "d" 
in the tree  rooted at "top" (including "top" itself).  "files" is a list
of all the files and subdirs in directory "d".
"""
    try:
        names = os.listdir(top)
    except os.error:
        return
    func(arg, top, names)
    exceptions = ('.', '..')
    for name in names:
        if name not in exceptions:
            name = join(top, name)
            if isdir(name):
                walk(name, func, arg)


# Expand paths beginning with '~' or '~user'.
# '~' means $HOME; '~user' means that user's home directory.
# If the path doesn't begin with '~', or if the user or $HOME is unknown,
# the path is returned unchanged (leaving error reporting to whatever
# function is called with the expanded path as argument).
# See also module 'glob' for expansion of *, ? and [...] in pathnames.
# (A function should also be defined to do full *sh-style environment
# variable expansion.)

def expanduser(path):
    """Expand ~ and ~user constructions.  If user or $HOME is unknown, 
do nothing"""
    if path[:1] <> '~':
        return path
    i, n = 1, len(path)
    while i < n and path[i] not in '/\\':
        i = i+1
    if i == 1:
        if os.environ.has_key('HOME'):
            userhome = os.environ['HOME']
        elif not os.environ.has_key('HOMEPATH'):
            return path
        else:
            try:
                drive=os.environ['HOMEDRIVE']
            except KeyError:
                drive = ''
            userhome = join(drive, os.environ['HOMEPATH'])
    else:
        return path
    return userhome + path[i:]


# Expand paths containing shell variable substitutions.
# The following rules apply:
#       - no expansion within single quotes
#       - no escape character, except for '$$' which is translated into '$'
#       - ${varname} is accepted.
#       - varnames can be made out of letters, digits and the character '_'
# XXX With COMMAND.COM you can use any characters in a variable name,
# XXX except '^|<>='.

varchars = string.letters + string.digits + '_-'

def expandvars(path):  
    """Expand shell variables of form $var and ${var}.  Unknown variables
are left unchanged"""
    if '$' not in path:
        return path
    res = ''
    index = 0
    pathlen = len(path)
    while index < pathlen:
        c = path[index]
        if c == '\'':   # no expansion within single quotes
            path = path[index + 1:]
            pathlen = len(path)
            try:
                index = string.index(path, '\'')
                res = res + '\'' + path[:index + 1]
            except string.index_error:
                res = res + path
                index = pathlen -1
        elif c == '$':  # variable or '$$'
            if path[index + 1:index + 2] == '$':
                res = res + c
                index = index + 1
            elif path[index + 1:index + 2] == '{':
                path = path[index+2:]
                pathlen = len(path)
                try:
                    index = string.index(path, '}')
                    var = path[:index]
                    if os.environ.has_key(var):
                        res = res + os.environ[var]
                except string.index_error:
                    res = res + path
                    index = pathlen - 1
            else:
                var = ''
                index = index + 1
                c = path[index:index + 1]
                while c != '' and c in varchars:
                    var = var + c
                    index = index + 1
                    c = path[index:index + 1]
                if os.environ.has_key(var):
                    res = res + os.environ[var]
                if c != '':
                    res = res + c
        else:
            res = res + c
        index = index + 1
    return res


# Normalize a path, e.g. A//B, A/./B and A/foo/../B all become A/B.
# Previously, this function also truncated pathnames to 8+3 format,
# but as this module is called "ntpath", that's obviously wrong!

def normpath(path):
    """Normalize path, eliminating double slashes, etc."""
    path = string.replace(path, "/", "\\")
    prefix, path = splitdrive(path)
    while path[:1] == os.sep:
        prefix = prefix + os.sep
        path = path[1:]
    comps = string.splitfields(path, os.sep)
    i = 0
    while i < len(comps):
        if comps[i] == '.':
            del comps[i]
        elif comps[i] == '..' and i > 0 and comps[i-1] not in ('', '..'):
            del comps[i-1:i+1]
            i = i-1
        elif comps[i] == '' and i > 0 and comps[i-1] <> '':
            del comps[i]
        else:
            i = i+1
    # If the path is now empty, substitute '.'
    if not prefix and not comps:
        comps.append('.')
    return prefix + string.joinfields(comps, os.sep)
