#!/bin/sh

set -e
#set -x

echo "lcdc_fb.1 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_mobile_lcdc_fb sh_mobile_lcdc_fb.1: registered sh_mobile_lcdc_fb.1/mainlcd as 1280x720 16bpp."
