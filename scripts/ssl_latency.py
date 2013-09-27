#!/usr/bin/env python
import sys
import subprocess

args = sys.argv
domain = args[1] if len(args) > 1 else "google.com"

print "calculating latency for connections to https://%s" % domain


args = ["curl", "-kso", "/dev/null", "-w",
        "\"tcp:%{time_connect}, ssldone:%{time_appconnect}\n\"",
        "https://%s" % domain]

ret = subprocess.check_output(args)
print ret[1:-1]

