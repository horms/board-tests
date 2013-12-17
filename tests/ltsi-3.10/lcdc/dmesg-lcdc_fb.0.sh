#!/bin/sh

set -e
#set -x

echo "lcdc_fb.0 dmesg feature test"

exec $(dirname $0)/../common/dmesg.sh "sh_mobile_lcdc_fb sh_mobile_lcdc_fb.0: registered sh_mobile_lcdc_fb.0/mainlcd as 800x480 16bpp."
