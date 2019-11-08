#!/usr/bin/env python3
import sys, argparse, tty, termios
from queue import Queue
from threading import Thread
import time
import json
import serial
from socket import *

def init_serial(devicename, baudrate):
    # Try to open the given device name
    try:
        s = serial.Serial(devicename, baudrate=baudrate, timeout=1)
    except serial.serialutil.SerialException:
        print('# Could not open ' + devicename)
        return False
    print('# Serial port opened: ' + s.name + ' @' + str(baudrate))
    s.flush()
    return s

### TODO Create Python class for board and tests etc.

parser = argparse.ArgumentParser()
parser.add_argument('config', metavar='config', default=None, nargs='?')
parser.add_argument('-v', dest='verbose', action='store_true',help='verbose')
parser.add_argument('-l', metavar='max num lines', dest='line_limit', type=int, default=0, help='exit after this many lines')

args = parser.parse_args()

if args.config == None:
    print("Config needed")
    sys.exit(1)

config=None
with open(args.config) as config_file:
    config = json.load(config_file)

if config == None:
    print("Not a valid config file")
    sys.exit(1)

sdev = []
for board in config['boards']:
    s = init_serial(board['serial_device'], board['baudrate'])
    if (s == False):
        exit(1)
    sdev.append(s)

nlines = 0
while True:
    line = sdev[0].readline().rstrip().decode('utf8')
    if (line and len(line)):
        try:
            d = json.loads(line);
        except:
            print("Err:"+line)
            continue

        if (args.verbose):
            print(d)
    nlines += 1
    if (args.line_limit and nlines > args.line_limit):
        print('# Line limit reached')
        break


