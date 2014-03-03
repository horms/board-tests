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

verbose = False

def err (str):
    print >>sys.stderr, "error: %s" % str

class Test:
    def __init__(self, board_hostname, board_username, ip_addr, target, log_file):
	self.board_hostname = board_hostname
	self.board_username = board_username
	self.ip_addr = ip_addr
	self.target = target
	self.log_file = log_file

# COMMON FUNCTION:
 
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

    def prepare_cmd(self, cmd):
	return [  ' '.join(cmd) ]

    def command(self):
	if self.target == "BOARD":
		cmd = ['iperf','-c', self.ip_addr, '>', '/dev/null' ]
	elif self.target == "PC":
		cmd = ['iperf','-c', self.ip_addr, '>', '/dev/null' ]
		cmd = self.board_cmd_args(cmd)
	return self.prepare_cmd(cmd)

# TCP CHECK:

#Case of transfer messages from board to PC:
    def transfer_mesg_to_pc(self, cmd):
	#Receive on pc:
	receive = subprocess.Popen([ 'iperf', '-s' ], stdout=subprocess.PIPE)
	time.sleep(2)
	if not receive:
        	print "Not ready to receive message"
		return False

	#Send from board:
	send = subprocess.call( cmd, shell=True)
	if send:
        	print "Send messages failed"
		return False
	time.sleep(2)
	if not try_kill(receive):
        	print "Kill Failed"
		return False
	output = receive.communicate()[0]
	if output:
        	f = open(self.log_file, 'w')
        	f.write(str(output))
        	f.close()

	return output

#------------------------------------------
#Case of transfer messages from PC to board:
    def transfer_mesg_to_board(self, cmd):
        #Receive on board:
	rev_cmd = ['iperf', '-s']
	rev_cmd = self.board_cmd_args(self.prepare_cmd(rev_cmd))
        receive = subprocess.Popen(rev_cmd, stdout=subprocess.PIPE)
	time.sleep(2)
	#exp: 'ssh', 'root@armadillo800','iperf -s'#
        if not receive:
                print "Not ready to receive message"
                return False

        #Send from board:
        send = subprocess.call(cmd, shell=True)
        if send:
                print "Send messages failed"
                return False
	time.sleep(2) 
        if not try_kill(receive):
                print "Kill Failed"
                return False
        output = receive.communicate()[0]
        if output:
                f = open(self.log_file, 'w')
                f.write(str(output))
                f.close()
        return True

#=======================================================
#Running program:

    def run(self):
	result = True	
	if self.target == "BOARD":
		out = self.transfer_mesg_to_board(self.command())
	elif self.target == "PC":
		out = self.transfer_mesg_to_pc(self.command())
	else:
		print "Unknown Target."
		result = False
	if not out:
		result = False

	return result



if len(sys.argv) < 1:
    err("Too few arguments\n")
try:
    opts, args = getopt.getopt(sys.argv[1:], "hv", [])
except getopt.GetoptError:
    err("Unknown arguments\n")

if len(sys.argv) < 5:
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
