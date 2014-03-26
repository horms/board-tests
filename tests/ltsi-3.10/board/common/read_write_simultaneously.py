#!/usr/bin/python
import errno
import sys
import subprocess
import os
import getopt
import time

def try_kill (proc):
    try:
        proc.kill()
    except OSError, e:
        if e.errno != errno.ESRCH:
            print >>sys.stderr, 'error: kill failed:', e
            return False

    return True

def err (str):
    print >>sys.stderr, "error: %s" % str

def fatal_err (str):
    err(str)
    exit(1)

class Test:
    def __init__(self, first_source, first_destination, last_source, last_destination, size):
        self.first_source = first_source
        self.first_destination = first_destination
        self.last_source = last_source
        self.last_destination = last_destination
	self.size = size

# Preparing a command before called
    def prepare_cmd(self, cmd):
	return [ ' '.join(cmd) ]

# Write data a the same time
    def write_data(self):
	cmd = [ 'dd', 'if=' + self.first_source, 'of=' + self.first_destination, \
	'bs=1M',  'count=' + self.size ]
	FIRST = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	if not FIRST:
		print "FIRST: Write a data failed"
		return False

	time.sleep(1)

	cmd = [ 'cp', self.last_source, self.last_destination ]
	cmd = self.prepare_cmd(cmd)
	LAST = subprocess.call(cmd, shell=True)

	if LAST:
		print "LAST: Write a data failed"
		return False

	FIRST.communicate()

        if not try_kill(FIRST):
                print "Kill Failed"
                return False

	return True
#=======================================================
#Running program:
    def run(self):
        result = True
        out = self.write_data()
        if not out:
                result = False

        return result

def usage():
        fatal_err(
"Usage: read_write_simultaneously.py FIRST_SOURCE FIRST_DISTINATION\\\n" +
"				LAST_SOURCE LAST_DISTINATION DATA_SIZE \\\n"
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"e.g:\n" +
"  read_write_simultaneously.py /tmp/file-10mb /mnt/sd0/file-10mb \
/tmp/file-10mb /mnt/sd1/file-10mb 10 \n"
    )

if len(sys.argv) < 1:
    err("Too few arguments\n")
    usage()
try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", [])
except getopt.GetoptError:
    err("Unknown arguments\n")
    usage()

if len(sys.argv) < 5:
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

