#!/usr/bin/python

# tty-ping.py
#
# Simple test for communication over a serial port-backed TTY
#
# Copyright (C) 2013 Horms Solutions Ltd.
#
# Contact: Simon Horman <horms@verge.net.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.

import errno
import getopt
import os
import select
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

def err_stdio(msg, outdata, errdata):
    msg += '\nStdout:'
    if outdata:
        msg += '\n' + outdata.rstrip('\r\n') + '\n'
    msg += '\nStderr:'
    if errdata:
        msg += '\n' + errdata.rstrip('\r\n') + '\n'
    err(msg.rstrip('\r\n'))

def err_proc(proc, msg, outdata, errdata):
    try_kill(proc)

    fds = [proc.stdout, proc.stderr]
    while fds:
        try:
            (r, w, e) = select.select(fds, [], fds, 0.1)
            if not r:
                break;
        except select.error, e:
            print >>sys.stderr, 'error: select failed:', e
            break

        for fd in r:
            data = fd.read()
            if data == '': # EOF
                fds.remove(fd)
                continue

            if fd == proc.stdout:
                outdata += data
            elif fd == proc.stderr:
                errdata += data
            else:
                break

    err_stdio(msg, outdata, errdata)
    proc.wait()

class Test:
    def __init__(self, local_tty, board_hostname, board_username, board_tty):
        self.local_tty = local_tty
        self.board_hostname = board_hostname
        self.board_username = board_username
        self.board_tty = board_tty

        self.board_stty = None
        self.local_stty = None

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

    def local_cmd_check_output(self, info_str, cmd):
        proc = self.start_cmd(info_str, cmd)
        if not proc:
            return (False, None)

        (outdata, errdata) = proc.communicate()
        if proc.returncode != 0:
            err_stdio(info_str, outdata, errdata)
            return (False, None)

        return (True, outdata)

    def local_cmd(self, info_str, cmd):
        return self.local_cmd_check_output(info_str, cmd)[0]

    def board_cmd_args(self, cmd):
        return ['ssh', self.board_hostname, '-l', self.board_username] + cmd

    def board_cmd_check_output(self, info_str, cmd):
        return self.local_cmd_check_output(info_str, self.board_cmd_args(cmd))

    def board_cmd(self, info_str, cmd):
        return self.local_cmd(info_str, self.board_cmd_args(cmd))

    def base_stty_args(self, tty):
        return [ 'stty', '-F', tty ]

    def set_stty_args(self, tty, speed, parity, stop_bits):
        cmd = self.base_stty_args(tty)
        cmd.append('speed')
        cmd.append(speed)

        if parity == 'none':
            cmd.append('-evenp')
        elif parity == 'even':
            cmd.append('evenp')
        else:
            fatal_err('Unknown stop_bits value \'%s\'. ' % stop_bits +
                      'Must be \'none\' or \'even\'')

        if stop_bits == '1':
            cmd.append('-cstopb')
        elif stop_bits == '2':
            cmd.append('cstopb')
        else:
            fatal_err('Unknown stop_bits value \'%s\'. ' % stop_bits +
                      'Must be \'1\' or \'2\'')

        return cmd

    def local_set_stty(self, info_str, speed, parity, stop_bits):
        cmd = self.set_stty_args(self.local_tty, speed, parity, stop_bits)
        return self.local_cmd(info_str, cmd)

    def board_set_stty(self, info_str, speed, parity, stop_bits):
        cmd = self.set_stty_args(self.board_tty, speed, parity, stop_bits)
        return self.board_cmd(info_str, cmd)

    def set_stty(self, speed, parity, stop_bits):
        info_str = 'Set stty'

        i_str = info_str + ': board'
        retcode = self.board_set_stty(i_str, speed, parity, stop_bits)
        if not retcode:
            return retcode

        i_str = info_str + ': local'
        return self.local_set_stty(i_str, speed, parity, stop_bits)

    def save_stty_args(self, tty):
        return self.base_stty_args(tty) + ['--save']

    def save_stty(self):
        info_str = 'Save stty'

        i_str = info_str + ': local tty'
        cmd = self.save_stty_args(self.local_tty)
        (retcode, outdata) = self.local_cmd_check_output(i_str, cmd)
        if not retcode:
            err(i_str)
            return False
        self.local_stty = outdata.rstrip('\r\n')

        i_str = info_str + ': board tty'
        cmd = self.save_stty_args(self.board_tty)
        (retcode, outdata) = self.board_cmd_check_output(i_str, cmd)
        if not retcode:
            err(i_str)
            return False
        self.board_stty = outdata.rstrip('\r\n')

        return True

    def restore_stty(self):
        info_str = 'Restore stty'
        retcode = True

        time.sleep(1)

        if self.board_stty:
            i_str = info_str + ': board tty'
            cmd = self.base_stty_args(self.board_tty)
            cmd.append(self.board_stty)
            if not self.board_cmd(i_str, cmd):
                err(i_str)
                retcode = False

        if self.local_stty:
            i_str = info_str + ': local tty'
            cmd = self.base_stty_args(self.local_tty)
            cmd.append(self.local_stty)
            if not self.local_cmd(i_str, cmd):
                err(i_str)
                retcode = False

        return retcode

    def echo_args(self, tty):
        return [ 'dd', 'bs=1', 'of=' + tty ]

    def echo(self, info_str, key, to_board):
        retcode = True

    	if to_board:
        	cmd = self.echo_args(self.local_tty)
	else:
        	cmd = self.board_cmd_args(self.echo_args(self.board_tty))

        proc = self.start_cmd(info_str, cmd, stdin=subprocess.PIPE)
        if not proc:
            return False

        (outdata, errdata) =  proc.communicate('\n' * 8 + key + '\n');
        if proc.returncode != 0:
           err_stdio(info_str, outdata, errdata)
           retcode = False
        #for i in ['\n'] * 8 + [key + '\n']:
        #    proc.stdin.write(i)
        #    time.sleep(1)

        if not try_kill(proc):
            retcode = False

        return retcode

    def monitor_args(self, tty):
        return [ 'dd', 'bs=1', 'if=' + tty ]

    def start_monitor(self, info_str, on_board):
	if on_board:
        	cmd = self.monitor_args(self.local_tty)
	else:
        	cmd = self.board_cmd_args(self.monitor_args(self.board_tty))

        return self.start_cmd(info_str, cmd)

    def collect_monitor(self, proc, info_str, expect):
        info(info_str)

        line = ""
        outdata = ""
        errdata = ""

        while True:
            if proc.poll():
                err_proc(proc, info_str, outdata, errdata)
                return False
            fds = [proc.stdout, proc.stderr]
            try:
                (r, w, e) = select.select(fds, [], fds, 10)
                if e or w:
                    err_proc(proc, info_str + ': select error', outdata, '')
                    return False
                if not r:
                    err_proc(proc, info_str + ': select timeout', outdata, '')
                    return False
            except select.error, e:
                print >>sys.stderr, 'error: select failed:', e
                return False

            fd = r[0]
            c = fd.read(1)
            if c == '': # EOF
                err_proc(proc, info_str + ': insufficient data read',
                         outdata, errdata)
                return False

            if fd == proc.stderr:
                errdata += c
                continue

            outdata += c
            if c != '\n':
                line += c
                continue

            if line == expect:
                ret = True
                if not try_kill(proc):
                    ret = False
                proc.wait()
                return ret

    def ping(self, param_str, to_board):
	if to_board:
		dir_str = 'to'
	else:
		dir_str = 'from'
	print 'Testing: %s board' % dir_str
	key = ', direction=' + dir_str

        # Start Monitor on Board
        info_str = 'Starting monitor'
        monitor = self.start_monitor(info_str, not to_board)
        if not monitor:
            return False

        info_str = 'Sending ping'
        retcode = self.echo(info_str, key, to_board)

        if retcode:
            info_str = 'Checking monitor'
            retcode = self.collect_monitor(monitor, info_str, key)

        info_str = 'Kill monitor'
        if not try_kill(monitor):
        	return False

        return retcode


    def run_one(self, speed, parity, stop_bits):
	retcode = True

        param_str = 'speed=\'%s\' parity=\'%s\', stop_bits=\'%s\'' % \
                (speed, parity, stop_bits)
        print 'Testing: ' + param_str
	
	for to_board in [ True, False ]:
		ret = self.ping(param_str, to_board)
		if not ret:
			retcode = False

        return retcode

    def run(self):
        ok = 0
        ng = 0
        status = True

        if not self.save_stty():
                return False

        for speed in ['115200', '9600']:
            for parity in ['none', 'even']:
                for stop_bits in ['1', '2']:
                    retval = self.run_one(speed, parity, stop_bits)
                    if retval:
                        ok = ok + 1
                    else:
                        ng = ng + 1

        print "Test Complete: Passed=%d Failed=%d" % (ok, ng)

        if ng != 0:
            status = False

        if not self.restore_stty():
            status = False

        return status

def usage():
        fatal_err(
"Usage: tty-ping.py [options] LOCAL_TTY \\\n" +
"                      BOARD_HOSTNAME BOARD_USERNAME BOARD_TTY\\\n" +
"  where:\n" +
"\n"
"    LOCAL_TTY:       TTY to use on local host\n"
"    BOARD_HOSTNAME:  Is the hostname of the board to connect to\n" +
"    BOARD_USERNAME:  Is the username to use when when loging into the board\n" +
"    BOARD_TTY:       TTY to use on board\n"
"\n" +
"  options:\n" +
"    -h: Dipslay this help message and exit\n" +
"    -v: Be versbose\n" +
"\n" +
"  e.g:\n" +
"    tty-ping.py /dev/ttyUSB0 armadillo800eva root /dev/ttySC1\n" +
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
