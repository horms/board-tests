#!/usr/bin/python

# udp_check.py
#
# Simple test for speed of ethernet 

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

def err (str):
    print >>sys.stderr, "error: %s" % str

def fatal_err (str):
    err(str)
    exit(1)

class Test:
    def __init__(self, board_hostname, board_username, log_file, target):
        self.board_hostname = board_hostname
        self.board_username = board_username
        self.log_file = log_file
        self.target = target

# COMMON FUNCTION:
# arguments to access to board via ssh:
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

# setting command with given arguments
    def set_cmd_args(self, option):
        return [ 'iperf', option, ]

#Preparing a command before called
    def prepare_cmd(self, cmd):
        return [ ' '.join(cmd) ]

    def udp_check_board(self, option):
	retcode = True
        cmd = self.board_cmd_args(self.prepare_cmd(self.set_cmd_args(option)))
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        if not proc:
		return False
        time.sleep(1)
        if not try_kill(proc):
		retcode = False
	
        return retcode

    def udp_check_pc(self):
	retcode = True
	#receive on PC:
	proc = subprocess.Popen([ 'iperf', '-s', '-u' ], stdout=subprocess.PIPE)
	if not proc:
        	print "Not ready to receive message"
		return False

	time.sleep(1)
#        if not try_kill(proc):
#		retcode = False

	return retcode
#==============================
# Running:
    def run(self):
	status = True
	if self.target == "BOARD":
		option = '-s -u'
        	val = self.udp_check_board(option)
	elif self.target == "HOSTPC":
		val = self.udp_check_pc()
	if not val:
		print "Receive Failed"
		status = False

        return status

# Help
def usage():
        fatal_err(
"Usage: udp_check.py [options] \\\n" +
"                       BOARD_HOSTNAME BOARD_USERNAME LOG_FILE TYPES DEVICE\\\n" +
"  where:\n" +
"\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n"
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"    LOG_FILE:        Is file to write mesg from board or HostPC\n" +
"    TARGET:	     Is TARGET to send to, that is BOARD or HOSTPC\n"     
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    udp_check.py armadillo800 root /tmp/udp.txt BOARD \n" +
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

if len(sys.argv) < 4:
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

