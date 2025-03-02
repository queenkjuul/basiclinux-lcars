'''An FTP client class, and some helper functions.
Based on RFC 959: File Transfer Protocol
(FTP), by J. Postel and J. Reynolds

Changes and improvements suggested by Steve Majewski.
Modified by Jack to work on the mac.
Modified by Siebren to support docstrings and PASV.


Example:

>>> from ftplib import FTP
>>> ftp = FTP('ftp.python.org') # connect to host, default port
>>> ftp.login() # default, i.e.: user anonymous, passwd user@hostname
'230 Guest login ok, access restrictions apply.'
>>> ftp.retrlines('LIST') # list directory contents
total 9
drwxr-xr-x   8 root     wheel        1024 Jan  3  1994 .
drwxr-xr-x   8 root     wheel        1024 Jan  3  1994 ..
drwxr-xr-x   2 root     wheel        1024 Jan  3  1994 bin
drwxr-xr-x   2 root     wheel        1024 Jan  3  1994 etc
d-wxrwxr-x   2 ftp      wheel        1024 Sep  5 13:43 incoming
drwxr-xr-x   2 root     wheel        1024 Nov 17  1993 lib
drwxr-xr-x   6 1094     wheel        1024 Sep 13 19:07 pub
drwxr-xr-x   3 root     wheel        1024 Jan  3  1994 usr
-rw-r--r--   1 root     root          312 Aug  1  1994 welcome.msg
'226 Transfer complete.'
>>> ftp.quit()
'221 Goodbye.'
>>> 

A nice test that reveals some of the network dialogue would be:
python ftplib.py -d localhost -l -p -l
'''


import os
import sys
import string

# Import SOCKS module if it exists, else standard socket module socket
try:
	import SOCKS; socket = SOCKS
except ImportError:
	import socket


# Magic number from <socket.h>
MSG_OOB = 0x1				# Process data out of band


# The standard FTP server control port
FTP_PORT = 21


# Exception raised when an error or invalid response is received
error_reply = 'ftplib.error_reply'	# unexpected [123]xx reply
error_temp = 'ftplib.error_temp'	# 4xx errors
error_perm = 'ftplib.error_perm'	# 5xx errors
error_proto = 'ftplib.error_proto'	# response does not begin with [1-5]


# All exceptions (hopefully) that may be raised here and that aren't
# (always) programming errors on our side
all_errors = (error_reply, error_temp, error_perm, error_proto, \
	      socket.error, IOError, EOFError)


# Line terminators (we always output CRLF, but accept any of CRLF, CR, LF)
CRLF = '\r\n'


# The class itself
class FTP:

	'''An FTP client class.

	To create a connection, call the class using these argument:
		host, user, passwd, acct
	These are all strings, and have default value ''.
	Then use self.connect() with optional host and port argument.

	To download a file, use ftp.retrlines('RETR ' + filename),
	or ftp.retrbinary() with slightly different arguments.
	To upload a file, use ftp.storlines() or ftp.storbinary(),
	which have an open file as argument (see their definitions
	below for details).
	The download/upload functions first issue appropriate TYPE
	and PORT or PASV commands.
'''

	# Initialization method (called by class instantiation).
	# Initialize host to localhost, port to standard ftp port
	# Optional arguments are host (for connect()),
	# and user, passwd, acct (for login())
	def __init__(self, host = '', user = '', passwd = '', acct = ''):
		# Initialize the instance to something mostly harmless
		self.debugging = 0
		self.host = ''
		self.port = FTP_PORT
		self.sock = None
		self.file = None
		self.welcome = None
		resp = None
		if host:
			resp = self.connect(host)
			if user: resp = self.login(user, passwd, acct)

	def connect(self, host = '', port = 0):
		'''Connect to host.  Arguments are:
		- host: hostname to connect to (string, default previous host)
		- port: port to connect to (integer, default previous port)'''
		if host: self.host = host
		if port: self.port = port
		self.passiveserver = 0
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.sock.connect(self.host, self.port)
		self.file = self.sock.makefile('rb')
		self.welcome = self.getresp()
		return self.welcome

	def getwelcome(self):
		'''Get the welcome message from the server.
		(this is read and squirreled away by connect())'''
		if self.debugging:
			print '*welcome*', self.sanitize(self.welcome)
		return self.welcome

	def set_debuglevel(self, level):
		'''Set the debugging level.
		The required argument level means:
		0: no debugging output (default)
		1: print commands and responses but not body text etc.
		2: also print raw lines read and sent before stripping CR/LF'''
		self.debugging = level
	debug = set_debuglevel

	def set_pasv(self, val):
		'''Use passive or active mode for data transfers.
		With a false argument, use the normal PORT mode,
		With a true argument, use the PASV command.'''
		self.passiveserver = val

	# Internal: "sanitize" a string for printing
	def sanitize(self, s):
		if s[:5] == 'pass ' or s[:5] == 'PASS ':
			i = len(s)
			while i > 5 and s[i-1] in '\r\n':
				i = i-1
			s = s[:5] + '*'*(i-5) + s[i:]
		return `s`

	# Internal: send one line to the server, appending CRLF
	def putline(self, line):
		line = line + CRLF
		if self.debugging > 1: print '*put*', self.sanitize(line)
		self.sock.send(line)

	# Internal: send one command to the server (through putline())
	def putcmd(self, line):
		if self.debugging: print '*cmd*', self.sanitize(line)
		self.putline(line)

	# Internal: return one line from the server, stripping CRLF.
	# Raise EOFError if the connection is closed
	def getline(self):
		line = self.file.readline()
		if self.debugging > 1:
			print '*get*', self.sanitize(line)
		if not line: raise EOFError
		if line[-2:] == CRLF: line = line[:-2]
		elif line[-1:] in CRLF: line = line[:-1]
		return line

	# Internal: get a response from the server, which may possibly
	# consist of multiple lines.  Return a single string with no
	# trailing CRLF.  If the response consists of multiple lines,
	# these are separated by '\n' characters in the string
	def getmultiline(self):
		line = self.getline()
		if line[3:4] == '-':
			code = line[:3]
			while 1:
				nextline = self.getline()
				line = line + ('\n' + nextline)
				if nextline[:3] == code and \
					nextline[3:4] <> '-':
					break
		return line

	# Internal: get a response from the server.
	# Raise various errors if the response indicates an error
	def getresp(self):
		resp = self.getmultiline()
		if self.debugging: print '*resp*', self.sanitize(resp)
		self.lastresp = resp[:3]
		c = resp[:1]
		if c == '4':
			raise error_temp, resp
		if c == '5':
			raise error_perm, resp
		if c not in '123':
			raise error_proto, resp
		return resp

	def voidresp(self):
		"""Expect a response beginning with '2'."""
		resp = self.getresp()
		if resp[0] <> '2':
			raise error_reply, resp
		return resp

	def abort(self):
		'''Abort a file transfer.  Uses out-of-band data.
		This does not follow the procedure from the RFC to send Telnet
		IP and Synch; that doesn't seem to work with the servers I've
		tried.  Instead, just send the ABOR command as OOB data.'''
		line = 'ABOR' + CRLF
		if self.debugging > 1: print '*put urgent*', self.sanitize(line)
		self.sock.send(line, MSG_OOB)
		resp = self.getmultiline()
		if resp[:3] not in ('426', '226'):
			raise error_proto, resp

	def sendcmd(self, cmd):
		'''Send a command and return the response.'''
		self.putcmd(cmd)
		return self.getresp()

	def voidcmd(self, cmd):
		"""Send a command and expect a response beginning with '2'."""
		self.putcmd(cmd)
		return self.voidresp()

	def sendport(self, host, port):
		'''Send a PORT command with the current host and the given port number.'''
		hbytes = string.splitfields(host, '.')
		pbytes = [`port/256`, `port%256`]
		bytes = hbytes + pbytes
		cmd = 'PORT ' + string.joinfields(bytes, ',')
		return self.voidcmd(cmd)

	def makeport(self):
		'''Create a new socket and send a PORT command for it.'''
		global nextport
		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.bind(('', 0))
		sock.listen(1)
		dummyhost, port = sock.getsockname() # Get proper port
		host, dummyport = self.sock.getsockname() # Get proper host
		resp = self.sendport(host, port)
		return sock

	def ntransfercmd(self, cmd):
		'''Initiate a transfer over the data connection.
		If the transfer is active, send a port command and
		the transfer command, and accept the connection.
		If the server is passive, send a pasv command, connect
		to it, and start the transfer command.
		Either way, return the socket for the connection and
		the expected size of the transfer.  The expected size
		may be None if it could not be determined.'''
		size = None
		if self.passiveserver:
			host, port = parse227(self.sendcmd('PASV'))
			conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			conn.connect(host, port)
			resp = self.sendcmd(cmd)
			if resp[0] <> '1':
				raise error_reply, resp
		else:
			sock = self.makeport()
			resp = self.sendcmd(cmd)
			if resp[0] <> '1':
				raise error_reply, resp
			conn, sockaddr = sock.accept()
		if resp[:3] == '150':
			# this is conditional in case we received a 125
			size = parse150(resp)
		return conn, size

	def transfercmd(self, cmd):
		'''Initiate a transfer over the data connection.  Returns
		the socket for the connection.  See also ntransfercmd().'''
		return self.ntransfercmd(cmd)[0]

	def login(self, user = '', passwd = '', acct = ''):
		'''Login, default anonymous.'''
		if not user: user = 'anonymous'
		if not passwd: passwd = ''
		if not acct: acct = ''
		if user == 'anonymous' and passwd in ('', '-'):
			thishost = socket.gethostname()
			# Make sure it is fully qualified
			if not '.' in thishost:
				thisaddr = socket.gethostbyname(thishost)
				firstname, names, unused = \
					   socket.gethostbyaddr(thisaddr)
				names.insert(0, firstname)
				for name in names:
					if '.' in name:
						thishost = name
						break
			try:
				if os.environ.has_key('LOGNAME'):
					realuser = os.environ['LOGNAME']
				elif os.environ.has_key('USER'):
					realuser = os.environ['USER']
				else:
					realuser = 'anonymous'
			except AttributeError:
				# Not all systems have os.environ....
				realuser = 'anonymous'
			passwd = passwd + realuser + '@' + thishost
		resp = self.sendcmd('USER ' + user)
		if resp[0] == '3': resp = self.sendcmd('PASS ' + passwd)
		if resp[0] == '3': resp = self.sendcmd('ACCT ' + acct)
		if resp[0] <> '2':
			raise error_reply, resp
		return resp

	def retrbinary(self, cmd, callback, blocksize=8192):
		'''Retrieve data in binary mode.
		The argument is a RETR command.
		The callback function is called for each block.
		This creates a new port for you'''
		self.voidcmd('TYPE I')
		conn = self.transfercmd(cmd)
		while 1:
			data = conn.recv(blocksize)
			if not data:
				break
			callback(data)
		conn.close()
		return self.voidresp()

	def retrlines(self, cmd, callback = None):
		'''Retrieve data in line mode.
		The argument is a RETR or LIST command.
		The callback function (2nd argument) is called for each line,
		with trailing CRLF stripped.  This creates a new port for you.
		print_lines is the default callback.'''
		if not callback: callback = print_line
		resp = self.sendcmd('TYPE A')
		conn = self.transfercmd(cmd)
		fp = conn.makefile('rb')
		while 1:
			line = fp.readline()
			if self.debugging > 2: print '*retr*', `line`
			if not line:
				break
			if line[-2:] == CRLF:
				line = line[:-2]
			elif line[:-1] == '\n':
				line = line[:-1]
			callback(line)
		fp.close()
		conn.close()
		return self.voidresp()

	def storbinary(self, cmd, fp, blocksize):
		'''Store a file in binary mode.'''
		self.voidcmd('TYPE I')
		conn = self.transfercmd(cmd)
		while 1:
			buf = fp.read(blocksize)
			if not buf: break
			conn.send(buf)
		conn.close()
		return self.voidresp()

	def storlines(self, cmd, fp):
		'''Store a file in line mode.'''
		self.voidcmd('TYPE A')
		conn = self.transfercmd(cmd)
		while 1:
			buf = fp.readline()
			if not buf: break
			if buf[-2:] <> CRLF:
				if buf[-1] in CRLF: buf = buf[:-1]
				buf = buf + CRLF
			conn.send(buf)
		conn.close()
		return self.voidresp()

	def acct(self, password):
		'''Send new account name.'''
		cmd = 'ACCT ' + password
		return self.voidcmd(cmd)

	def nlst(self, *args):
		'''Return a list of files in a given directory (default the current).'''
		cmd = 'NLST'
		for arg in args:
			cmd = cmd + (' ' + arg)
		files = []
		self.retrlines(cmd, files.append)
		return files

	def dir(self, *args):
		'''List a directory in long form.
		By default list current directory to stdout.
		Optional last argument is callback function; all
		non-empty arguments before it are concatenated to the
		LIST command.  (This *should* only be used for a pathname.)'''
		cmd = 'LIST' 
		func = None
		if args[-1:] and type(args[-1]) != type(''):
			args, func = args[:-1], args[-1]
		for arg in args:
			if arg:
				cmd = cmd + (' ' + arg) 
		self.retrlines(cmd, func)

	def rename(self, fromname, toname):
		'''Rename a file.'''
		resp = self.sendcmd('RNFR ' + fromname)
		if resp[0] <> '3':
			raise error_reply, resp
		return self.voidcmd('RNTO ' + toname)

	def delete(self, filename):
		'''Delete a file.'''
		resp = self.sendcmd('DELE ' + filename)
		if resp[:3] == '250':
			return resp
		elif resp[:1] == '5':
			raise error_perm, resp
		else:
			raise error_reply, resp

	def cwd(self, dirname):
		'''Change to a directory.'''
		if dirname == '..':
			try:
				return self.voidcmd('CDUP')
			except error_perm, msg:
				if msg[:3] != '500':
					raise error_perm, msg
		cmd = 'CWD ' + dirname
		return self.voidcmd(cmd)

	def size(self, filename):
		'''Retrieve the size of a file.'''
		# Note that the RFC doesn't say anything about 'SIZE'
		resp = self.sendcmd('SIZE ' + filename)
		if resp[:3] == '213':
			return string.atoi(string.strip(resp[3:]))

	def mkd(self, dirname):
		'''Make a directory, return its full pathname.'''
		resp = self.sendcmd('MKD ' + dirname)
		return parse257(resp)

	def rmd(self, dirname):
		'''Remove a directory.'''
		return self.voidcmd('RMD ' + dirname)

	def pwd(self):
		'''Return current working directory.'''
		resp = self.sendcmd('PWD')
		return parse257(resp)

	def quit(self):
		'''Quit, and close the connection.'''
		resp = self.voidcmd('QUIT')
		self.close()
		return resp

	def close(self):
		'''Close the connection without assuming anything about it.'''
		self.file.close()
		self.sock.close()
		del self.file, self.sock


_150_re = None

def parse150(resp):
	'''Parse the '150' response for a RETR request.
	Returns the expected transfer size or None; size is not guaranteed to
	be present in the 150 message.
	'''
	if resp[:3] != '150':
		raise error_reply, resp
	global _150_re
	if _150_re is None:
		import re
		_150_re = re.compile("150 .* \(([0-9][0-9]*) bytes\)",
				     re.IGNORECASE)
	m = _150_re.match(resp)
	if m:
		return string.atoi(m.group(1))
	return None


def parse227(resp):
	'''Parse the '227' response for a PASV request.
	Raises error_proto if it does not contain '(h1,h2,h3,h4,p1,p2)'
	Return ('host.addr.as.numbers', port#) tuple.'''

	if resp[:3] <> '227':
		raise error_reply, resp
	left = string.find(resp, '(')
	if left < 0: raise error_proto, resp
	right = string.find(resp, ')', left + 1)
	if right < 0:
		raise error_proto, resp	# should contain '(h1,h2,h3,h4,p1,p2)'
	numbers = string.split(resp[left+1:right], ',')
	if len(numbers) <> 6:
		raise error_proto, resp
	host = string.join(numbers[:4], '.')
	port = (string.atoi(numbers[4]) << 8) + string.atoi(numbers[5])
	return host, port


def parse257(resp):
	'''Parse the '257' response for a MKD or PWD request.
	This is a response to a MKD or PWD request: a directory name.
	Returns the directoryname in the 257 reply.'''

	if resp[:3] <> '257':
		raise error_reply, resp
	if resp[3:5] <> ' "':
		return '' # Not compliant to RFC 959, but UNIX ftpd does this
	dirname = ''
	i = 5
	n = len(resp)
	while i < n:
		c = resp[i]
		i = i+1
		if c == '"':
			if i >= n or resp[i] <> '"':
				break
			i = i+1
		dirname = dirname + c
	return dirname


def print_line(line):
	'''Default retrlines callback to print a line.'''
	print line


def ftpcp(source, sourcename, target, targetname = '', type = 'I'):
	'''Copy file from one FTP-instance to another.'''
	if not targetname: targetname = sourcename
	type = 'TYPE ' + type
	source.voidcmd(type)
	target.voidcmd(type)
	sourcehost, sourceport = parse227(source.sendcmd('PASV'))
	target.sendport(sourcehost, sourceport)
	# RFC 959: the user must "listen" [...] BEFORE sending the
	# transfer request.
	# So: STOR before RETR, because here the target is a "user".
	treply = target.sendcmd('STOR ' + targetname)
	if treply[:3] not in ('125', '150'): raise error_proto	# RFC 959
	sreply = source.sendcmd('RETR ' + sourcename)
	if sreply[:3] not in ('125', '150'): raise error_proto	# RFC 959
	source.voidresp()
	target.voidresp()


class Netrc:
	"""Class to parse & provide access to 'netrc' format files.

	See the netrc(4) man page for information on the file format.

	"""
	__defuser = None
	__defpasswd = None
	__defacct = None

	def __init__(self, filename=None):
		if not filename:
			if os.environ.has_key("HOME"):
				filename = os.path.join(os.environ["HOME"],
							".netrc")
			else:
				raise IOError, \
				      "specify file to load or set $HOME"
		self.__hosts = {}
		self.__macros = {}
		fp = open(filename, "r")
		in_macro = 0
		while 1:
			line = fp.readline()
			if not line: break
			if in_macro and string.strip(line):
				macro_lines.append(line)
				continue
			elif in_macro:
				self.__macros[macro_name] = tuple(macro_lines)
				in_macro = 0
			words = string.split(line)
			host = user = passwd = acct = None
			default = 0
			i = 0
			while i < len(words):
				w1 = words[i]
				if i+1 < len(words):
					w2 = words[i + 1]
				else:
					w2 = None
				if w1 == 'default':
					default = 1
				elif w1 == 'machine' and w2:
					host = string.lower(w2)
					i = i + 1
				elif w1 == 'login' and w2:
					user = w2
					i = i + 1
				elif w1 == 'password' and w2:
					passwd = w2
					i = i + 1
				elif w1 == 'account' and w2:
					acct = w2
					i = i + 1
				elif w1 == 'macdef' and w2:
					macro_name = w2
					macro_lines = []
					in_macro = 1
					break
				i = i + 1
			if default:
				self.__defuser = user or self.__defuser
				self.__defpasswd = passwd or self.__defpasswd
				self.__defacct = acct or self.__defacct
			if host:
				if self.__hosts.has_key(host):
					ouser, opasswd, oacct = \
					       self.__hosts[host]
					user = user or ouser
					passwd = passwd or opasswd
					acct = acct or oacct
				self.__hosts[host] = user, passwd, acct
		fp.close()

	def get_hosts(self):
		"""Return a list of hosts mentioned in the .netrc file."""
		return self.__hosts.keys()

	def get_account(self, host):
		"""Returns login information for the named host.

		The return value is a triple containing userid,
		password, and the accounting field.

		"""
		host = string.lower(host)
		user = passwd = acct = None
		if self.__hosts.has_key(host):
			user, passwd, acct = self.__hosts[host]
		user = user or self.__defuser
		passwd = passwd or self.__defpasswd
		acct = acct or self.__defacct
		return user, passwd, acct

	def get_macros(self):
		"""Return a list of all defined macro names."""
		return self.__macros.keys()

	def get_macro(self, macro):
		"""Return a sequence of lines which define a named macro."""
		return self.__macros[macro]



def test():
	'''Test program.
	Usage: ftp [-d] [-r[file]] host [-l[dir]] [-d[dir]] [-p] [file] ...'''

	debugging = 0
	rcfile = None
	while sys.argv[1] == '-d':
		debugging = debugging+1
		del sys.argv[1]
	if sys.argv[1][:2] == '-r':
		# get name of alternate ~/.netrc file:
		rcfile = sys.argv[1][2:]
		del sys.argv[1]
	host = sys.argv[1]
	ftp = FTP(host)
	ftp.set_debuglevel(debugging)
	userid = passwd = acct = ''
	try:
		netrc = Netrc(rcfile)
	except IOError:
		if rcfile is not None:
			sys.stderr.write("Could not open account file"
					 " -- using anonymous login.")
	else:
		try:
			userid, passwd, acct = netrc.get_account(host)
		except KeyError:
			# no account for host
			sys.stderr.write(
				"No account -- using anonymous login.")
	ftp.login(userid, passwd, acct)
	for file in sys.argv[2:]:
		if file[:2] == '-l':
			ftp.dir(file[2:])
		elif file[:2] == '-d':
			cmd = 'CWD'
			if file[2:]: cmd = cmd + ' ' + file[2:]
			resp = ftp.sendcmd(cmd)
		elif file == '-p':
			ftp.set_pasv(not ftp.passiveserver)
		else:
			ftp.retrbinary('RETR ' + file, \
				       sys.stdout.write, 1024)
	ftp.quit()


if __name__ == '__main__':
	test()
