import string
import sys
from types import StringType


AS_IS = None


class NullFormatter:

    def __init__(self, writer=None):
        if not writer:
            writer = NullWriter()
        self.writer = writer
    def end_paragraph(self, blankline): pass
    def add_line_break(self): pass
    def add_hor_rule(self, *args, **kw): pass
    def add_label_data(self, format, counter, blankline=None): pass
    def add_flowing_data(self, data): pass
    def add_literal_data(self, data): pass
    def flush_softspace(self): pass
    def push_alignment(self, align): pass
    def pop_alignment(self): pass
    def push_font(self, x): pass
    def pop_font(self): pass
    def push_margin(self, margin): pass
    def pop_margin(self): pass
    def set_spacing(self, spacing): pass
    def push_style(self, *styles): pass
    def pop_style(self, n=1): pass
    def assert_line_data(self, flag=1): pass


class AbstractFormatter:

    #  Space handling policy:  blank spaces at the boundary between elements
    #  are handled by the outermost context.  "Literal" data is not checked
    #  to determine context, so spaces in literal data are handled directly
    #  in all circumstances.

    def __init__(self, writer):
        self.writer = writer            # Output device
        self.align = None               # Current alignment
        self.align_stack = []           # Alignment stack
        self.font_stack = []            # Font state
        self.margin_stack = []          # Margin state
        self.spacing = None             # Vertical spacing state
        self.style_stack = []           # Other state, e.g. color
        self.nospace = 1                # Should leading space be suppressed
        self.softspace = 0              # Should a space be inserted
        self.para_end = 1               # Just ended a paragraph
        self.parskip = 0                # Skipped space between paragraphs?
        self.hard_break = 1             # Have a hard break
        self.have_label = 0

    def end_paragraph(self, blankline):
        if not self.hard_break:
            self.writer.send_line_break()
            self.have_label = 0
        if self.parskip < blankline and not self.have_label:
            self.writer.send_paragraph(blankline - self.parskip)
            self.parskip = blankline
            self.have_label = 0
        self.hard_break = self.nospace = self.para_end = 1
        self.softspace = 0

    def add_line_break(self):
        if not (self.hard_break or self.para_end):
            self.writer.send_line_break()
            self.have_label = self.parskip = 0
        self.hard_break = self.nospace = 1
        self.softspace = 0

    def add_hor_rule(self, *args, **kw):
        if not self.hard_break:
            self.writer.send_line_break()
        apply(self.writer.send_hor_rule, args, kw)
        self.hard_break = self.nospace = 1
        self.have_label = self.para_end = self.softspace = self.parskip = 0

    def add_label_data(self, format, counter, blankline = None):
        if self.have_label or not self.hard_break:
            self.writer.send_line_break()
        if not self.para_end:
            self.writer.send_paragraph((blankline and 1) or 0)
        if type(format) is StringType:
            self.writer.send_label_data(self.format_counter(format, counter))
        else:
            self.writer.send_label_data(format)
        self.nospace = self.have_label = self.hard_break = self.para_end = 1
        self.softspace = self.parskip = 0

    def format_counter(self, format, counter):
        label = ''
        for c in format:
            try:
                if c == '1':
                    label = label + ('%d' % counter)
                elif c in 'aA':
                    if counter > 0:
                        label = label + self.format_letter(c, counter)
                elif c in 'iI':
                    if counter > 0:
                        label = label + self.format_roman(c, counter)
                else:
                    label = label + c
            except:
                label = label + c
        return label

    def format_letter(self, case, counter):
        label = ''
        while counter > 0:
            counter, x = divmod(counter-1, 26)
            s = chr(ord(case) + x)
            label = s + label
        return label

    def format_roman(self, case, counter):
        ones = ['i', 'x', 'c', 'm']
        fives = ['v', 'l', 'd']
        label, index = '', 0
        # This will die of IndexError when counter is too big
        while counter > 0:
            counter, x = divmod(counter, 10)
            if x == 9:
                label = ones[index] + ones[index+1] + label
            elif x == 4:
                label = ones[index] + fives[index] + label
            else:
                if x >= 5:
                    s = fives[index]
                    x = x-5
                else:
                    s = ''
                s = s + ones[index]*x
                label = s + label
            index = index + 1
        if case == 'I':
            return string.upper(label)
        return label

    def add_flowing_data(self, data,
                         # These are only here to load them into locals:
                         whitespace = string.whitespace,
                         join = string.join, split = string.split):
        if not data: return
        # The following looks a bit convoluted but is a great improvement over
        # data = regsub.gsub('[' + string.whitespace + ']+', ' ', data)
        prespace = data[:1] in whitespace
        postspace = data[-1:] in whitespace
        data = join(split(data))
        if self.nospace and not data:
            return
        elif prespace or self.softspace:
            if not data:
                if not self.nospace:
                    self.softspace = 1
                    self.parskip = 0
                return
            if not self.nospace:
                data = ' ' + data
        self.hard_break = self.nospace = self.para_end = \
                          self.parskip = self.have_label = 0
        self.softspace = postspace
        self.writer.send_flowing_data(data)

    def add_literal_data(self, data):
        if not data: return
        if self.softspace:
            self.writer.send_flowing_data(" ")
        self.hard_break = data[-1:] == '\n'
        self.nospace = self.para_end = self.softspace = \
                       self.parskip = self.have_label = 0
        self.writer.send_literal_data(data)

    def flush_softspace(self):
        if self.softspace:
            self.hard_break = self.para_end = self.parskip = \
                              self.have_label = self.softspace = 0
            self.nospace = 1
            self.writer.send_flowing_data(' ')

    def push_alignment(self, align):
        if align and align != self.align:
            self.writer.new_alignment(align)
            self.align = align
            self.align_stack.append(align)
        else:
            self.align_stack.append(self.align)

    def pop_alignment(self):
        if self.align_stack:
            del self.align_stack[-1]
        if self.align_stack:
            self.align = align = self.align_stack[-1]
            self.writer.new_alignment(align)
        else:
            self.align = None
            self.writer.new_alignment(None)

    def push_font(self, (size, i, b, tt)):
        if self.softspace:
            self.hard_break = self.para_end = self.softspace = 0
            self.nospace = 1
            self.writer.send_flowing_data(' ')
        if self.font_stack:
            csize, ci, cb, ctt = self.font_stack[-1]
            if size is AS_IS: size = csize
            if i is AS_IS: i = ci
            if b is AS_IS: b = cb
            if tt is AS_IS: tt = ctt
        font = (size, i, b, tt)
        self.font_stack.append(font)
        self.writer.new_font(font)

    def pop_font(self):
        if self.font_stack:
            del self.font_stack[-1]
        if self.font_stack:
            font = self.font_stack[-1]
        else:
            font = None
        self.writer.new_font(font)

    def push_margin(self, margin):
        self.margin_stack.append(margin)
        fstack = filter(None, self.margin_stack)
        if not margin and fstack:
            margin = fstack[-1]
        self.writer.new_margin(margin, len(fstack))

    def pop_margin(self):
        if self.margin_stack:
            del self.margin_stack[-1]
        fstack = filter(None, self.margin_stack)
        if fstack:
            margin = fstack[-1]
        else:
            margin = None
        self.writer.new_margin(margin, len(fstack))

    def set_spacing(self, spacing):
        self.spacing = spacing
        self.writer.new_spacing(spacing)

    def push_style(self, *styles):
        if self.softspace:
            self.hard_break = self.para_end = self.softspace = 0
            self.nospace = 1
            self.writer.send_flowing_data(' ')
        for style in styles:
            self.style_stack.append(style)
        self.writer.new_styles(tuple(self.style_stack))

    def pop_style(self, n=1):
        del self.style_stack[-n:]
        self.writer.new_styles(tuple(self.style_stack))

    def assert_line_data(self, flag=1):
        self.nospace = self.hard_break = not flag
        self.para_end = self.parskip = self.have_label = 0


class NullWriter:
    """Minimal writer interface to use in testing & inheritance."""
    def __init__(self): pass
    def flush(self): pass
    def new_alignment(self, align): pass
    def new_font(self, font): pass
    def new_margin(self, margin, level): pass
    def new_spacing(self, spacing): pass
    def new_styles(self, styles): pass
    def send_paragraph(self, blankline): pass
    def send_line_break(self): pass
    def send_hor_rule(self, *args, **kw): pass
    def send_label_data(self, data): pass
    def send_flowing_data(self, data): pass
    def send_literal_data(self, data): pass


class AbstractWriter(NullWriter):

    def __init__(self):
        pass

    def new_alignment(self, align):
        print "new_alignment(%s)" % `align`

    def new_font(self, font):
        print "new_font(%s)" % `font`

    def new_margin(self, margin, level):
        print "new_margin(%s, %d)" % (`margin`, level)

    def new_spacing(self, spacing):
        print "new_spacing(%s)" % `spacing`

    def new_styles(self, styles):
        print "new_styles(%s)" % `styles`

    def send_paragraph(self, blankline):
        print "send_paragraph(%s)" % `blankline`

    def send_line_break(self):
        print "send_line_break()"

    def send_hor_rule(self, *args, **kw):
        print "send_hor_rule()"

    def send_label_data(self, data):
        print "send_label_data(%s)" % `data`

    def send_flowing_data(self, data):
        print "send_flowing_data(%s)" % `data`

    def send_literal_data(self, data):
        print "send_literal_data(%s)" % `data`


class DumbWriter(NullWriter):

    def __init__(self, file=None, maxcol=72):
        self.file = file or sys.stdout
        self.maxcol = maxcol
        NullWriter.__init__(self)
        self.reset()

    def reset(self):
        self.col = 0
        self.atbreak = 0

    def send_paragraph(self, blankline):
        self.file.write('\n' + '\n'*blankline)
        self.col = 0
        self.atbreak = 0

    def send_line_break(self):
        self.file.write('\n')
        self.col = 0
        self.atbreak = 0

    def send_hor_rule(self, *args, **kw):
        self.file.write('\n')
        self.file.write('-'*self.maxcol)
        self.file.write('\n')
        self.col = 0
        self.atbreak = 0

    def send_literal_data(self, data):
        self.file.write(data)
        i = string.rfind(data, '\n')
        if i >= 0:
            self.col = 0
            data = data[i+1:]
        data = string.expandtabs(data)
        self.col = self.col + len(data)
        self.atbreak = 0

    def send_flowing_data(self, data):
        if not data: return
        atbreak = self.atbreak or data[0] in string.whitespace
        col = self.col
        maxcol = self.maxcol
        write = self.file.write
        for word in string.split(data):
            if atbreak:
                if col + len(word) >= maxcol:
                    write('\n')
                    col = 0
                else:
                    write(' ')
                    col = col + 1
            write(word)
            col = col + len(word)
            atbreak = 1
        self.col = col
        self.atbreak = data[-1] in string.whitespace


def test(file = None):
    w = DumbWriter()
    f = AbstractFormatter(w)
    if file:
        fp = open(file)
    elif sys.argv[1:]:
        fp = open(sys.argv[1])
    else:
        fp = sys.stdin
    while 1:
        line = fp.readline()
        if not line:
            break
        if line == '\n':
            f.end_paragraph(1)
        else:
            f.add_flowing_data(line)
    f.end_paragraph(0)


if __name__ == '__main__':
    test()
