#!/usr/bin/env python
import sys
import SimpleHTTPServer
import SocketServer

if len(sys.argv) <= 1:
    PORT = 8000
elif len(sys.argv) == 2:
    PORT = int(sys.argv[1])
else:
    print "Too many args: ", str(sys.argv)
    sys.exit(1)

Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
httpd = SocketServer.TCPServer(("", PORT), Handler)
print "serving at port", PORT
httpd.serve_forever()

