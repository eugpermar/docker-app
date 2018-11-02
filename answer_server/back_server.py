#!/usr/bin/env python2

from __future__ import print_function

from sys import argv

import SocketServer


class MyTCPHandler(SocketServer.StreamRequestHandler):
    def handle(self):
        self.wfile.write('42')
        self.wfile.flush()


if __name__ == "__main__":
    HOST = "0.0.0.0"
    try:
        PORT = int(argv[1])
    except IndexError:
        PORT = 9998

    # Create the server
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    print('(DB) Listening on port {port}'.format(port=PORT))

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
