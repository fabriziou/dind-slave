#!/bin/bash

/usr/local/bin/wrapdocker
service docker start
exec /usr/sbin/sshd -D
