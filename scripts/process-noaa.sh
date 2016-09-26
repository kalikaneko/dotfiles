#!/bin/sh
sox $1 -c 1 output.wav rate 11025 avg -b
atpdec -s 18 -i ab output.wav
