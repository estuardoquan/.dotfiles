#!/usr/bin/python3

import bcrypt
import sys

from getopt import GetoptError, getopt
from getpass import getpass
from pprint import pprint

def usage(c = 1, m = None):
    if m:
        print(m)
    print('usage: encrypt [-b | --bytes NAMES] [-o | --out FILE]')
    sys.exit(c)

def fnv1a(value):
    # FNV-1a 32-bit parameters
    FNV_PRIME = 16777619
    FNV_OFFSET = 2166136261
    # Convert to bytes
    if not isinstance(value, bytes):
        value = str(value).encode('utf-8')
    # Compute hash
    hash_val = FNV_OFFSET
    for byte in value:
        hash_val ^= byte
        hash_val = (hash_val * FNV_PRIME) & 0xFFF  # Keep within 32 bits
    return hash_val

# Get command argv and exclude file
argv = sys.argv[1:]

file = ''
string = ''

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
            string = arg
        case '-o' | '--out':
            file = arg

if string == '':
    l = 0;
    while True:
        i = input("Enter something (type 'q' to quit): ")
        if i.lower() == 'q':
            break
        if l == 0:
            string += i
        else:
            string += ',' + i
        l = l + 1

data = string.split(',')

# Convert the password to bytes

# Generate the salt

# Compute the password hash

# Convert hash to string
hashes = []
if file == '':
    # Print hashed password to stdout
    for item in data:
        h = fnv1a(item)
        if h in hashes:
            exit(f'{item}:{h} collided')
        hashes.append(h)
        print(f'{h:04d}, {item}')
else:
    # Print hashed password to file
    f = open(file, 'w')
    for item in data:
        h = fnv1a(item)
        if h in hashes:
            exit(f'{item}:{h} collided')
        hashes.append(h)
        f.write(f"'{h:04d}, {item}\n")
    f.close()
