#!/usr/bin/env python
# Added by <ctang@redhat.com>
# Added on Sept 14 2012
'''
LISTEN-TO-LEAP

Get used to the rythm of your bugs.
Using the aud gem: https://github.com/dzello/aud
but wrapping it up in a little of python... just because.

No, seriously, aud is hanging when I launch more than one process.

Using also the following skeleton:

A pipeline made of several coroutines
that can be turned off gracefully.

This script is inspired by David Beazley with his PyCon 09 talks.
Based on his ideas, I have extended a bit to make the pipeline
able to be monitored and turned off gracefully.
'''
file_name = '/tmp/leap.log'

from sh import echo
from sh import aud


play = lambda string, note, time, octave: aud(
    echo(string),
    "-n", "%s" % note,
    "-d", time,
    "-o", octave)

CR = "\n"
matched_lines = lambda pat, buf: CR.join(
    [line for line in buf.split(CR) if pat in line])

# since we're spawning new processes, we cannot
# control the duration...
# So, we batch them in buffers of three of more lines.


def contains_info(lines):
    buf = "\n".join(lines)[:-1]
    if "FETCH" in buf:
        buf = matched_lines("FETCH", buf)
        play(buf, "G", 20, 3)
        return True
    if "rcv:" in buf:
        buf = matched_lines("rcv:", buf)
        play(buf, "F", 10, 3)
        return True
    return False


def contains_error(line):
    buf = line[:-1]
    if "Exception" in buf:
        play(buf, "A", 2000, 2)
        return True
    if "LOGOUT" in buf:
        play(buf, "B", 200, 4)
        play(buf, "C", 1000, 5)
        return True
    return False

# =====================###################


def coroutine(func):
    '''A decorator that advances
    the execution to the first 'yield'
    in a generator so that this generator
    is "primed".
    '''
    def generator(*args, **kwargs):
        primed_func = func(*args, **kwargs)
        primed_func.next()
        return primed_func
    return generator


def turn_off_when_too_long(line):
    if len(line) > 1000:
        return True
    return False


def tail(target_file, target):
    '''Mimic Unix tail -f
    This is the source of the pipeline
    a pipeline must have a source.
    '''
    # Moves to the end of file
    target_file.seek(0, 2)
    try:
        while True:
            line = target_file.readline()
            if line:
                target.send(line)
            else:
                #time.sleep(0.001)
                continue
    except StopIteration:
        print "Pipeline Ended"


@coroutine
def printer():
    '''Display the line
    This is the end-point(sink) of the pipeline.
    '''
    try:
        while True:
            line = (yield)
    except GeneratorExit:
        print 'Printer Pipeline Ended'


def check(line, error, target):
    if error(line):
        print "sending ERROR ---------"
        target.send(line)


@coroutine
def grep(pattern_check, target):
    buf = []

    error, info = pattern_check
    try:
        while True:
            line = (yield)
            buf.append(line)
            if len(buf) > 3:
                if info(buf):
                    target.send(buf)
                    buf = []
                    check(line, error, target)
                else:
                    continue
            else:
                check(line, error, target)
                continue

    except GeneratorExit:
        print "Grep Pipeline Ended"
        target.close()


@coroutine
def monitor(pattern_check, target):
    while True:
        line = (yield)
        if pattern_check(line):
            break
        else:
            target.send(line)
    target.close()


def main():
    f = open(file_name)
    tail(f, monitor(turn_off_when_too_long, grep((
        contains_error, contains_info), printer())))

if __name__ == '__main__':
    print "[+ listening to the sounds of your backtrace!]"
    main()
