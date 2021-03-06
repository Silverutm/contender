#!/bin/bash

echo -n 'stopping judge... ' >&2
(killall 'perl-fcgi-pm [Judge]' 2> /dev/null && echo '[OK]' >& 2) || echo '[FAILED]' >&2

echo    'starting judge... ' >&2
unbuffer ./judge_fastcgi.pl --listen 127.0.0.1:30115 --keeperr 2>&1 | tee ./error.log
echo 'finished.'
