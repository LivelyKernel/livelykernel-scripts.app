#!/usr/bin/env bash --login

binname=node
which $binname
retval=$? # 0 if exists, 1 otherwise
# weird, for packagemker is 1 = install, 0 = not install
exit $retval
