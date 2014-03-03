#!/usr/bin/python

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

class Test:
    def __init__(self, board_hostname, board_username, pc_device, board_devive):
	self.board_hostname = board_hostname
	self.board_username = board_username
	self.pc_device = pc_device
	self.board_devive = board_devive

# COMMON FUNCTION:
 
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

    def prepare_cmd (self, cmd):
	return [  ' '.join(cmd) ]

    def command (self, mesg):
	ping = ['"/bin/echo', mesg, '>', '/dev/' + self.board_devive + '"' ]
	cmd = self.board_cmd_args(ping)
	return self.prepare_cmd(cmd)

# Case of transfer messages from board to PC:
# Transfer a message:
    def transfer_message(self, cmd):
	receive = subprocess.Popen([ 'cat', '/dev/' + self.pc_device ], stdout=subprocess.PIPE)
        if not receive:
                print "Not ready to receive message"
		return False
	send = subprocess.call( cmd , shell=True)
	if send:
		print "Send messages failed"
		return False

	if not try_kill(receive):
		print "Kill Failed"
        	return False

	output = receive.communicate()[0]
	if output:
		f = open('/tmp/text.txt', 'w')
		f.write(str(output))
		f.close()
	return output

# Check for messages come from board:
    def check_mesg(self, mesg):
	confirm = True
	check = [ 'cat', '/tmp/text.txt', '|', 'grep', mesg ]
	cmd = self.prepare_cmd(check)
	if subprocess.call(cmd, shell=True):
		print "Failed"
		confirm = False

	return confirm

#=======================================================
#Running program:

    def run(self):
	result = True	
	time.sleep(10)
	mesg = '"I am fine, thanks!"'
	if not self.transfer_message(self.command(mesg)):
		return False
	if not self.check_mesg(mesg):
		return False
	os.remove('/tmp/text.txt')

	return result



if len(sys.argv) < 1:
    err("Too few arguments\n")
try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", [])
except getopt.GetoptError:
    err("Unknown arguments\n")

if len(sys.argv) < 4:
    err("Too few arguments\n")

for opt, arg in opts:
    if opt == '-h':
        usage();
    if opt == '-v':
        verbose = True

test = Test(*args)
retval = test.run()
if retval == False:
    exit(1)
