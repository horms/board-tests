#!/bin/sh

set -e
#set -x

echo "sh_cmt.0 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_cmt sh_cmt.0: used for clock events"
