'''
align_string.py

Align string with spaces between words to fit specified width

Author: Denis Barmenkov <denis.barmenkov@gmail.com>

Copyright: this code is free, but if you want to use it,
           please keep this multiline comment along with function source.
           Thank you.

2005-05-22 13:27 - first revision
2010-03-09 17:01 - added align_paragraph()
2010-03-09 17:56 - added check for paragraph's last line
'''
import re, textwrap

__author__ = 'Denis Barmenkov <denis.barmenkov@gmail.com>'
__source__ = 'http://code.activestate.com/recipes/414870/'

def items_len(l):
    return sum([ len(x) for x in l] )

lead_re = re.compile(r'(^\s+)(.*)$')

def align_string(s, width, last_paragraph_line=0):
    '''
    align string to specified width
    '''
    # detect and save leading whitespace
    m = lead_re.match(s)
    if m is None:
        left, right, w = '', s, width
    else:
        left, right, w = m.group(1), m.group(2), width - len(m.group(1))

    items = right.split()

    # add required space to each words, exclude last item
    for i in range(len(items) - 1):
        items[i] += ' '

    if not last_paragraph_line:
        # number of spaces to add
        left_count = w - items_len(items)
        while left_count > 0 and len(items) > 1:
            for i in range(len(items) - 1):
                items[i] += ' '
                left_count -= 1
                if left_count < 1:
                    break

    res = left + ''.join(items)
    return res

def align_paragraph(paragraph, width, debug=0):
    '''
    align paragraph to specified width,
    returns list of paragraph lines
    '''
    lines = list()
    if type(paragraph) == type(lines):
        lines.extend(paragraph)
    elif type(paragraph) == type(''):
        lines.append(paragraph)
    elif type(paragraph) == type(tuple()):
        lines.extend(list(paragraph))
    else:
        raise TypeError, 'Unsopported paragraph type: %r' % type(paragraph)

    flatten_para = ' '.join(lines)

    splitted = textwrap.wrap(flatten_para, width)
    if debug:
        print 'textwrap:\n%s\n' % '\n'.join(splitted)

    wrapped = list()
    while len(splitted) > 0:
        line = splitted.pop(0)
        if len(splitted) == 0:
            last_paragraph_line = 1
        else:
            last_paragraph_line = 0
        aligned = align_string(line, width, last_paragraph_line)
        wrapped.append(aligned)

    if debug:
        print 'textwrap & align_string:\n%s\n' % '\n'.join(wrapped)

    return wrapped


if __name__ == '__main__':
    import sys
    input_file = sys.argv[1]
    lines = open(input_file).readlines()
    bigstr = '\n'.join(lines)

    final = []

    for paragraph in bigstr.split('\n\n\n\n'):
        aligned = align_paragraph(paragraph, 72)
        for line in aligned:
            final.append(line + '\n')
        final.append('\n')
    print ''.join(final)
