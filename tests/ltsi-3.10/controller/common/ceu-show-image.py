#!/usr/bin/python

import errno
import getopt
import os
import subprocess
import sys
import time
import signal

def try_kill (proc):
    try:
        proc.kill()
    except OSError, e:
        if e.errno != errno.ESRCH:
            print >>sys.stderr, 'error: kill failed:', e
            return False

    return True

class Test:
    def __init__(self, board_username, board_hostname):
	self.board_username = board_username
	self.board_hostname = board_hostname

    def board_cmd_args(self, cmd):
	return ['ssh', self.board_username + '@' + self.board_hostname, ] + cmd

    def show_image(self):
	cmd = [ 'DISPLAY=:0 gst-launch-0.10 v4l2src ! \
	"video/x-raw-yuv,width=800,height=480,format=(fourcc)NV12" ! \
	ffmpegcolorspace ! autovideosink' ]
	cmd = self.board_cmd_args(cmd)
	pipes = {'stdout':subprocess.PIPE, 'stderr':subprocess.PIPE}

	proc = subprocess.Popen(cmd, **pipes)
	if not proc:
       		print "Not ready to receive message"
	time.sleep(5)

	if not try_kill(proc):
       		print "Kill Failed"

	(output, errout) = proc.communicate()
	if errout:
		print "TEST FAILED!"
	else:
		print "TEST PASSED"

	return output

    def run(self):
        status = True
        if not self.show_image():
                return False

        return status

def usage():
        fatal_err(
"Usage: ceu_show_image.py [options] BOARD_USERNAME BOARD_HOSTNAME\n" +
"  where:\n" +
"\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n" +
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    ceu_show_image.py root armadillo800\n" +
""
    )

if len(sys.argv) < 1:
    err("Too few arguments\n")
    usage()
try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", [])
except getopt.GetoptError:
    err("Unknown arguments\n")
    usage()

if len(sys.argv) < 2:
    err("Too few arguments\n")
    usage()

for opt, arg in opts:
    if opt == '-h':
        usage();
    if opt == '-v':
        verbose = True

test = Test(*args)
retval = test.run()
if retval == False:
    exit(1)

