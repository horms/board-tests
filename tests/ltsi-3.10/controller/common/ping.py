#!/usr/bin/python

# udp-ctp-check.py
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

def info (str):
    if verbose:
        print str
    pass

class Test:
    def __init__(self, ip_addr):
        self.ip_addr = ip_addr

# setting command with given arguments
    def set_cmd_args(self, option):
        return [ 'ping', option, self.ip_addr ]

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

    def ping(self, info_str, option):
        retcode = True
	cmd = self.set_cmd_args(option)
        proc = self.start_cmd(info_str, cmd, stdin=subprocess.PIPE)
        if not proc:
            return False

        time.sleep(1)
        if not try_kill(proc):
           retcode = False

        return retcode

#==============================
# Running:
    def run(self):
        ng = 0
        ok = 0
        status = True
        info_str = 'Reveive data'
        option = '-c 20'
        val = self.ping(info_str, option)
        if not val:
                print "Receive Failed"
                status = False

        return status

# Help
def usage():
        fatal_err(
"Usage: ping.py [options] IP_ADDR \n" +
"  where:\n" +
"\n"
"    IP_ADDR:  Is the IP address of the board to connect to\n"
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    ping.py 172.16.1.36 \n" +
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

for opt, arg in opts:
    if opt == '-h':
        usage();
    if opt == '-v':
        verbose = True

test = Test(*args)
retval = test.run()
if retval == False:
    exit(1)

