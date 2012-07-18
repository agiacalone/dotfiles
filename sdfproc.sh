#!/usr/pkg/bin/bash 

NUMPROC=`ps u anthonyg | grep -v -e 'ps u anthonyg' -e "grep -v -e ps" -e sdfproc | wc -l`

echo "proc: $(($NUMPROC-1))"
