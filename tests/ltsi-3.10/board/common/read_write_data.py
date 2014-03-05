#!/usr/bin/python
import errno
import sys
import subprocess
import os
import getopt

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
    def __init__(self, path_source, path_destination, size, log_file):
        self.path_source = path_source
        self.path_destination = path_destination
        self.size = size
        self.log_file = log_file

    def write_data(self):
	cmd = [ 'dd', 'if=' + self.path_source, 'of=' + self.path_destination + \
	'/file-' + self.size + 'mb', 'bs=1M',  'count=' + self.size ]
	receive = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	(output, errout) = receive.communicate()
	if errout:
		f = open(self.log_file, 'w')
		f.write(str(errout))
		f.close()

        if not try_kill(receive):
                print "Kill Failed"
                return False

	return errout
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
"Usage: write_data.py PATH_SOURCE PATH_DISTINATION FILE_SIZE LOG_FILE\n " +
"For example: write_data.py /dev/urandom /media/storage 100 /tmp/storage.txt\n"
    )

if len(sys.argv) < 1:
    err("Too few arguments\n")
    usage()
try:
    opts, args = getopt.getopt(sys.argv[1:], [])
except getopt.GetoptError:
    err("Unknown arguments\n")
    usage()

if len(sys.argv) < 4:
    err("Too few arguments\n")
    usage()

test = Test(*args)
retval = test.run()
if retval == False:
    exit(1)

