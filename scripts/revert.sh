#!/bin/bash
for i in `cat /tmp/commits-revert`
do
    git revert $i
done
