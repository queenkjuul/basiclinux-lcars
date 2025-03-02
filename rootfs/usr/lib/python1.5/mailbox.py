#! /usr/bin/env python

"""Classes to handle Unix style, MMDF style, and MH style mailboxes."""


import rfc822
import os

class _Mailbox:

	def __init__(self, fp):
		self.fp = fp
		self.seekp = 0

	def seek(self, pos, whence=0):
		if whence==1:		# Relative to current position
			self.pos = self.pos + pos
		if whence==2:		# Relative to file's end
			self.pos = self.stop + pos
		else:			# Default - absolute position
			self.pos = self.start + pos

	def next(self):
		while 1:
			self.fp.seek(self.seekp)
			try:
				self._search_start()
			except EOFError:
				self.seekp = self.fp.tell()
				return None
			start = self.fp.tell()
			self._search_end()
			self.seekp = stop = self.fp.tell()
			if start <> stop:
				break
		return rfc822.Message(_Subfile(self.fp, start, stop))

class _Subfile:

	def __init__(self, fp, start, stop):
		self.fp = fp
		self.start = start
		self.stop = stop
		self.pos = self.start

	def read(self, length = None):
		if self.pos >= self.stop:
			return ''
		if length is None:
			length = self.stop - self.pos
		self.fp.seek(self.pos)
		self.pos = self.pos + length
		return self.fp.read(length)

	def readline(self, length = None):
		if self.pos >= self.stop:
			return ''
		if length is None:
			length = self.stop - self.pos
		self.fp.seek(self.pos)
		data = self.fp.readline(length)
		if len(data) < length:
			length = len(data)
		self.pos = self.pos + length
		return data

	def tell(self):
		return self.pos - self.start

	def seek(self, pos, whence=0):
		if whence == 0:
			self.pos = self.start + pos
		elif whence == 1:
			self.pos = self.pos + pos
		elif whence == 2:
			self.pos = self.stop + pos

	def close(self):
		pass

class UnixMailbox(_Mailbox):

	def _search_start(self):
		while 1:
			line = self.fp.readline()
			if not line:
				raise EOFError
			if line[:5] == 'From ' and self._isrealfromline(line):
				return

	def _search_end(self):
		while 1:
			pos = self.fp.tell()
			line = self.fp.readline()
			if not line:
				return
			if line[:5] == 'From ' and self._isrealfromline(line):
				self.fp.seek(pos)
				return

	# An overridable mechanism to test for From-line-ness.
	# You can either specify a different regular expression
	# or define a whole new _isrealfromline() method.
	# Note that this only gets called for lines starting with
	# the 5 characters "From ".

	_fromlinepattern = r"From \s*[^\s]+\s+\w\w\w\s+\w\w\w\s+\d?\d\s+" \
			   r"\d?\d:\d\d:\d\d(\s+[^\s]+)?\s+\d\d\d\d\s*$"
	_regexp = None

	def _isrealfromline(self, line):
		if not self._regexp:
			import re
			self._regexp = re.compile(self._fromlinepattern)
		return self._regexp.match(line)

class MmdfMailbox(_Mailbox):

	def _search_start(self):
		while 1:
			line = self.fp.readline()
			if not line:
				raise EOFError
			if line[:5] == '\001\001\001\001\n':
				return

	def _search_end(self):
		while 1:
			pos = self.fp.tell()
			line = self.fp.readline()
			if not line:
				return
			if line == '\001\001\001\001\n':
				self.fp.seek(pos)
				return

class MHMailbox:

	def __init__(self, dirname):
		import re
		pat = re.compile('^[0-9][0-9]*$')
		self.dirname = dirname
		files = os.listdir(self.dirname)
		self.boxes = []
		for f in files:
			if pat.match(f):
				self.boxes.append(f)

	def next(self):
		if not self.boxes:
			return None
		fn = self.boxes[0]
		del self.boxes[0]
		fp = open(os.path.join(self.dirname, fn))
		return rfc822.Message(fp)
	    
    
class BabylMailbox(_Mailbox):

	def _search_start(self):
		while 1:
			line = self.fp.readline()
			if not line:
				raise EOFError
			if line == '*** EOOH ***\n':
				return

	def _search_end(self):
		while 1:
			pos = self.fp.tell()
			line = self.fp.readline()
			if not line:
				return
			if line == '\037\014\n':
				self.fp.seek(pos)
				return


def _test():
	import time
	import sys
	import string
	import os

	args = sys.argv[1:]
	if not args:
		for key in 'MAIL', 'LOGNAME', 'USER':
			if os.environ.has_key(key):
				mbox = os.environ[key]
				break
		else:
			print "$MAIL, $LOGNAME nor $USER set -- who are you?"
			return
	else:
		mbox = args[0]
	if mbox[:1] == '+':
		mbox = os.environ['HOME'] + '/Mail/' + mbox[1:]
	elif not '/' in mbox:
		mbox = '/usr/mail/' + mbox
	if os.path.isdir(mbox):
		mb = MHMailbox(mbox)
	else:
		fp = open(mbox, 'r')
		mb = UnixMailbox(fp)
	
	msgs = []
	while 1:
		msg = mb.next()
		if msg is None:
			break
		msgs.append(msg)
		msg.fp = None
	if len(args) > 1:
		num = string.atoi(args[1])
		print 'Message %d body:'%num
		msg = msgs[num-1]
		msg.rewindbody()
		sys.stdout.write(msg.fp.read())
	else:
		print 'Mailbox',mbox,'has',len(msgs),'messages:'
		for msg in msgs:
			f = msg.getheader('from') or ""
			s = msg.getheader('subject') or ""
			d = msg.getheader('date') or ""
			print '%20.20s   %18.18s   %-30.30s'%(f, d[5:], s)


if __name__ == '__main__':
	_test()
