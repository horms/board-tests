#!/usr/bin/python

# sdhi_read_write.py
#
# Simple test for sdhi 

import errno
import getopt
import os
import subprocess
import sys
import time

def try_kill (proc):
    try:
        proc.kill()
    except OSError, e:
        if e.errno != errno.ESRCH:
            print >>sys.stderr, 'error: kill failed:', e
            return False

    return True

verbose = False

def info (str):
    if verbose:
        print str
    pass

def err (str):
    print >>sys.stderr, "error: %s" % str

def fatal_err (str):
    err(str)
    exit(1)

class Test:
    def __init__(self, board_hostname, board_username, mode):
        self.board_hostname = board_hostname
        self.board_username = board_username
	self.mode = mode

#Call subprocess to send command
    def call_cmd(self, cmd):
        run_cmd = subprocess.call(cmd, stderr=subprocess.PIPE)
#	run_cmd = subprocess.call(cmd)
        return run_cmd

# arguments to access to board via ssh:
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

# setting command with given arguments
    def set_cmd_args(self):
	return [ 'dd', 'if=/dev/urandom', 'of=/mnt/file', 'bs=1M count=10' ]

    def set_cmd_read(self):
	return [ 'dd', 'if=/mnt/file', 'of=/tmp/file' ]
#Preparing a command before called
    def prepare_cmd(self, cmd):
        return [ ' '.join(cmd) ]

    def start_cmd(self, info_str, cmd, stdin=None):
        info(info_str)
        info('start_cmd: ' + ' '.join(cmd))	

        pipes = {'stdout':subprocess.PIPE, 'stderr':subprocess.PIPE}
	if stdin:
            pipes['stdin'] = stdin

        try:
            proc = subprocess.Popen(cmd, **pipes)
	except OSError as e:
            print >>sys.stderr, 'error: ' + info_str + ': execution failed:', e
            return None
	
        return proc

    def operation(self, info_str):
        retcode = True
	if self.mode == "WRITE":
		print "Writing data to device..."
        	cmd = self.board_cmd_args(self.prepare_cmd(self.set_cmd_args()))
	elif self.mode == "READ":
		print "Writing data to device before read."
		write = self.call_cmd(self.board_cmd_args(self.prepare_cmd(self.set_cmd_args())))
		if write == 0:
			time.sleep (3)
                        print "Reading data from device..."
                        cmd = self.board_cmd_args(self.prepare_cmd(self.set_cmd_read()))
		else:
			print "Could not write data to device"
	else:
		return False
	proc = self.start_cmd(info_str, cmd, stdin=subprocess.PIPE)
        if not proc:
            return False

        time.sleep(2)
        if not try_kill(proc):
           retcode = False
	

        return retcode

#==============================
# Running:
    def run(self):
        status = True
	if self.mode == "WRITE":
		info_str = 'Writing data'
	elif self.mode == "READ":
		info_str = 'Reading data'
	else:
		status = False
        val = self.operation(info_str)
        if not val:
                print "Operation Failed"
                status = False

        return status

# Help
def usage():
        fatal_err(
"Usage: sdhi_read_write.py [options] \\\n" +
"                       BOARD_HOSTNAME BOARD_USERNAME MODE\\\n" +
"  where:\n" +
"\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n"
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"    MODE:	      Is READ data mode or WRITE data mode\n" +  
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    sdhi_read_write.py armadillo800 root WRITE \n" +
""
    )

#----------------------------
# Checking arguments and run
if len(sys.argv) < 1:
    err("Too few arguments\n")
    usage()
try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", [])
except getopt.GetoptError:
    err("Unknown arguments\n")
    usage()

if len(sys.argv) < 3:
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

