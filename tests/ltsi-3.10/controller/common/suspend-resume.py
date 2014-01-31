#!/usr/bin/python

# suspend.py
#
# Simple test for PM over a ssh and wakeup via a serial port

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

def err_stdio(msg, outdata, errdata):
    msg += '\nStdout:'
    if outdata:
        msg += '\n' + outdata.rstrip('\r\n') + '\n'
    msg += '\nStderr:'
    if errdata:
        msg += '\n' + errdata.rstrip('\r\n') + '\n'
    err(msg.rstrip('\r\n'))

class Test:
    def __init__(self, local_tty, board_hostname, board_username, board_tty, sci_id):
        self.local_tty = local_tty
        self.board_hostname = board_hostname
        self.board_username = board_username
	self.board_tty = board_tty
	self.sci_id = sci_id

#Call subprocess to send command
    def call_cmd(self, cmd):
	run_cmd = subprocess.call(cmd, stderr=subprocess.PIPE)
	return run_cmd

# arguments to access to board via ssh:
    def board_cmd_args(self, cmd):
        return ['ssh',self.board_username + '@' + self.board_hostname ] + cmd

# setting command with given arguments
    def base_cmd_args(self, mesg):
        return [ '/bin/echo', mesg, '>' ]

    def set_cmd_args(self, mesg):
        cmd = self.base_cmd_args(mesg)
	if mesg == 'enabled':
		cmd.append('/sys/devices/platform/sh-sci.' + str(self.sci_id) + \
                           '/tty/ttySC' + str(self.sci_id) +'/power/wakeup')
	elif mesg == 'mem':
       		cmd.append('/sys/power/state')
	elif mesg == 'probe':
		cmd.append('/dev/null')
	elif mesg == 'wakeup':
		cmd.append('/dev/null')
	else:
            print 'Unknown this command'

        return cmd

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

    def echo_args(self, tty):
        return [ 'dd', 'bs=1', 'of=' + tty ]

    def wakeup(self, info_str, key):
        retcode = True
        cmd = self.echo_args(self.local_tty)

        proc = self.start_cmd(info_str, cmd, stdin=subprocess.PIPE)
        if not proc:
            return False

	(outdata, errdata) =  proc.communicate('\n' * 1 + key + '\n');
        if proc.returncode != 0:
           err_stdio(info_str, outdata, errdata)
           retcode = False

        if not try_kill(proc):
            retcode = False

        return retcode

    def suspend(self, info_str, mesg):
        retcode = True
	par_str = self.prepare_cmd(self.set_cmd_args(mesg))
        cmd = self.board_cmd_args(par_str)

        proc = self.start_cmd(info_str, cmd, stdin=subprocess.PIPE)
        if not proc:
            return False

	time.sleep(2)
        if not try_kill(proc):
           retcode = False

        return retcode

    def send_data(self, mesg):

	if mesg == 'enabled':
		print "Current progress setting the wakeup device..."
	elif mesg == 'probe':
		print "Check the suspending system..."
	elif mesg == 'wakeup':
		print "Current progress checking wakeup device..."
	else:
		print "Unknown value:%s" % (mesg)

	param_str = self.prepare_cmd(self.set_cmd_args(mesg))
	cal_cmd = self.call_cmd(self.board_cmd_args(param_str))
	
	return cal_cmd
#==============================
# Running:
    def run(self):
	ng = 0
	ok = 0
        status = True
	# Setting the wakeup device and suspend system 
        for mesg in [ 'enabled', 'mem', 'probe' ]:
		
		if mesg == 'enabled':
			retval = self.send_data(mesg)
			if (retval == 0):
				print "Setting the wakeup device successfully!"
			else:
				print "Setting the wakeup device Failed!"
				status = False
		elif mesg == 'mem':
			info_str = 'Suspending'
			print "Current progress suspending system..."
			retval = self.suspend(info_str, mesg)
			if not retval:
				print "Suspending Failed!"
                		status = False
		elif mesg == 'probe':
			time.sleep(1)
			retval = self.send_data(mesg)
			if (retval == 0):
				print "System hasn't been suspended!"
				ng = ng + 1
			else:
				print "System is Suspending successfully!"
				info_str = 'send a data to wakup device'
				key = ' '
				# Send a data to board via serialport to wakeup system.
				data = self.wakeup(info_str, key)
				if not data:
					print "Send a data failed!"
					ng = ng + 1
				else:
					time.sleep(2)
					mesg = 'wakeup'
					check = self.send_data(mesg)
					if (check == 0):
						print "System has been waked up!"
						ok = ok + 1
					else:
						print "wakeup the system failed!!" 
						ng = ng + 1
		else:
			status = False

        print "Test Complete: Passed=%d Failed=%d" % (ok, ng)
        if ng != 0:
        	status = False

        return status

# Help
def usage():
        fatal_err(
"Usage: suspend.py [options] LOCAL_TTY \\\\n" +
"                       BOARD_HOSTNAME BOARD_USERNAME BOARD_TTY SCI_ID\\\\n" +
"  where:\n" +
"\n"
"    LOCAL_TTY:       TTY to use on local host\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n" +
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"    BOARD_TTY:       TTY to use on board\n"+
"    SCI_ID:	      The ID that Serial port using for each board"	
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    suspend.py /dev/ttyUSB0 armadillo800 root /dev/ttySC1 1 \n" +
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

if len(sys.argv) < 6:
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


