#!/usr/bin/python3

import bcrypt
import sys

from getopt import GetoptError, getopt
from getpass import getpass

def usage(c = 1, m = None):
    if m:
        print(m)
    print('usage: encrypt [-b | --bytes PASSWORD] [-o | --out FILE]')
    sys.exit(c)
    
# Get command argv and exclude file
argv = sys.argv[1:]

file = ''
password = ''

# Define the getopt parameters
try:
    opts, args = getopt(argv, 'b:o:', ['bytes=', 'out='])
except GetoptError:
    usage(2)

if len(args) > 0:
    usage(3,'Command does not accept any arguments')
    
for opt, arg in opts:
    match opt:
        case '-b' | '--bytes':
            password = arg
        case '-o' | '--out':
            file = arg

if password == '':
    password = getpass('Enter password:')

# Convert the password to bytes
bytes = password.encode('utf-8')

# Generate the salt
salt = bcrypt.gensalt()

# Compute the password hash
hash = bcrypt.hashpw(bytes, salt)

# Convert hash to string
hstr = hash.decode()

if file == '':
    # Print hashed password to stdout
    print(hstr)
else:
    # Print hashed password to file
    f = open(file, 'w')
    f.write(hstr + '\n')
    f.close()
