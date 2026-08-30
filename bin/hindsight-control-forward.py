#!/usr/bin/env python3
"""TCP forwarder: Tailscale IP :7878 -> 127.0.0.1:7878 (Hindsight control center).

Resolves the Tailscale IPv4 at startup via `tailscale ip -4` (or
/Applications/Tailscale.app/Contents/MacOS/Tailscale). Exits non-zero if
unresolvable so launchd retries. Binds ONLY the Tailscale IP, never 0.0.0.0.
"""
import fcntl
import socket
import struct
import subprocess
import sys
import threading

LISTEN_PORT = int(__import__("os").environ.get("HC_FORWARD_PORT", "7878"))
TARGET = ("127.0.0.1", 7878)


def tailscale_ip():
    for cand in (
        ["/Applications/Tailscale.app/Contents/MacOS/Tailscale", "ip", "-4"],
        ["tailscale", "ip", "-4"],
    ):
        try:
            out = subprocess.run(cand, capture_output=True, text=True, timeout=10)
            ip = out.stdout.strip().splitlines()[0].strip() if out.returncode == 0 and out.stdout.strip() else ""
            if ip:
                return ip
        except (OSError, subprocess.TimeoutExpired, IndexError):
            continue
    return ""


def is_tailscale_iface(ip):
    """Confirm the IP sits on a utun interface (100.64.0.0/10 CGNAT range)."""
    first = struct.unpack("!I", socket.inet_aton(ip))[0]
    net = struct.unpack("!I", socket.inet_aton("100.64.0.0"))[0]
    mask = struct.unpack("!I", socket.inet_aton("255.192.0.0"))[0]
    return (first & mask) == (net & mask)


def pipe(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            dst.sendall(data)
    except OSError:
        pass
    finally:
        try:
            dst.shutdown(socket.SHUT_WR)
        except OSError:
            pass
        src.close()
        dst.close()


def handle(client):
    try:
        upstream = socket.create_connection(TARGET, timeout=5)
    except OSError:
        client.close()
        return
    t = threading.Thread(target=pipe, args=(client, upstream), daemon=True)
    t.start()
    pipe(upstream, client)


def main():
    ip = tailscale_ip()
    if not ip or not is_tailscale_iface(ip):
        print(f"no tailscale ip resolved ({ip!r}), exiting for retry", flush=True)
        return 1
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        srv.bind((ip, LISTEN_PORT))
    except OSError as e:
        print(f"bind {ip}:{LISTEN_PORT} failed: {e}", flush=True)
        return 1
    srv.listen(16)
    print(f"forwarding {ip}:{LISTEN_PORT} -> {TARGET[0]}:{TARGET[1]}", flush=True)
    while True:
        try:
            client, addr = srv.accept()
        except OSError:
            return 1
        threading.Thread(target=handle, args=(client,), daemon=True).start()


if __name__ == "__main__":
    sys.exit(main())
