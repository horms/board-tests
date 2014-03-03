#!/usr/bin/python

# Simple test for speed of usb function 

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
    def __init__(self, board_hostname, board_username, log_file, device):
        self.board_hostname = board_hostname
        self.board_username = board_username
        self.log_file = log_file
        self.device = device

# arguments to access to board via ssh:
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

# setting command with given arguments
    def set_cmd_args(self, option):
	return [ '/bin/cat', '/dev/'+ option + ' >', self.log_file ]

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

    def send_mesg(self, info_str, option):
        retcode = True
        cmd = self.board_cmd_args(self.prepare_cmd(self.set_cmd_args(option)))
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
	info_str = 'Send message from pc to board'
	option = self.device
        val = self.send_mesg(info_str, option)
        if not val:
                print "Receive Failed"
                status = False

        return status

# Help
def usage():
        fatal_err(
"Usage: usb-function-serial.py [options] \\\n" +
"                       BOARD_HOSTNAME BOARD_USERNAME LOG_FILE DEVICE \\\n" +
"  where:\n" +
"\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n"
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"    LOG_FILE:        Is file to write mesg from board or pc\n" +
"    DEVICE:	      Is usb serial function device file in /dev/\n"  
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    usb-function-serial.py armadillo800 root /tmp/text.txt ttyGS0 \n" +
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

