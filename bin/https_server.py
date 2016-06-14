import BaseHTTPServer, SimpleHTTPServer
import ssl

print "https://localhost:4443/"
httpd = BaseHTTPServer.HTTPServer(('localhost', 4443), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket(httpd.socket, certfile='C:/tsk/bin/server.pem', server_side=True)
httpd.serve_forever()
