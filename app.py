#!/usr/bin/env python2

from __future__ import print_function

from datetime import datetime
from os import makedirs
from sys import stdout

import errno
import SocketServer
import subprocess


def isonow():
    return datetime.utcnow().isoformat()


class Tee(object):
    def __init__(self, *args):
        self.file_handlers = args

    def print(self, str):
        for f in self.file_handlers:
            print(str, file=f)


class MyTCPHandler(SocketServer.StreamRequestHandler):
    def handle(self):
        client_addr = self.client_address
        start_timestamp = isonow()
        filename = 'logs/log.{timestamp}'.format(timestamp=start_timestamp)

        try:
            makedirs('logs')
        except OSError as e:
            if e.errno is not errno.EEXIST:
                raise e

        with open(filename, 'w') as f:
            tee_log = Tee(f, stdout)
            tee_log.print('{timestamp}: Client {client} connected'.format(
                          timestamp=start_timestamp,
                          client=client_addr))

            bin_line = self.rfile.readline().strip()

            tee_log.print(
                '{timestamp}: {client} want to execute {bin_line}'.format(
                    timestamp=isonow(),
                    client=client_addr,
                    bin_line=bin_line))

            p = subprocess.Popen(bin_line,
                                 shell=True,
                                 stdout=self.wfile,
                                 stderr=self.wfile,
                                 stdin=self.rfile)
            p.wait()

            tee_log.print('{timestamp}: Client {client} out'.format(
                          timestamp=isonow(),
                          client=client_addr))


if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 9999

    # Create the server
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    print('Listening on port {port}'.format(port=PORT))

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
