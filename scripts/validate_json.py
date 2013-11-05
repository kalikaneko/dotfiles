#!/usr/bin/env python
"""
Validates if a given file is proper json.
"""
import json
import sys


def validate(path):
    try:
        with open(path) as content:
            #print "path is: ", path
            json.loads(content.read())
        print "OK"
        exit(0)
    except Exception as exc:
        print "ERROR: %r" % exc
        exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print "Usage: validate_json <path_to_file>"
        exit(0)
    f = sys.argv[1]
    validate(f)
