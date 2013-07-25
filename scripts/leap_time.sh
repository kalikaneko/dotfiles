#!/bin/sh
# Display interesting timezones
# in the leap universe.

alias datetime="date +%H:%M"

echo "~~~~~~~~~~~~~~"
echo "    LEAP      "
echo "  UNIVERSAL   "
echo "    TIME      "
echo '~~~~~~~~~~~~~~'

echo 'sf:\t' `TZ="America/Los_Angeles" datetime`
echo 'ny:\t' `TZ="America/New_York" datetime`
echo 'UTC\t' `TZ="Europe/London" datetime`
echo 'berlin:\t' `TZ="Europe/Berlin" datetime`
echo 'seoul:\t' `TZ="Asia/Seoul" datetime`
