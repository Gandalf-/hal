import threading
import webbrowser
import BaseHTTPServer
import SimpleHTTPServer

FILE = 'index.html'
PORT = 8000

class DemoHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
  '''The dynamic part, maybe'''

  def do_POST(self):
    '''Handle a post request by returning the square'''
    length = int(self.headers.getheader('content-length'))
    data_string = self.rfile.read(length)
    try:
      result = data_string[::-1] + " | " + data_string
    except:
      result = 'error'
    self.wfile.write(result)

def open_browser():
  '''Start a browser after waiting a bit'''
  def _open_browser():
    webbrowser.open('http://localhost:%s/%s' % (PORT, FILE))
    thread = threading.Timer(0.5, _open_browser)
    thread.start()

def start_server():
  '''Start the server'''
  server_address = ("", PORT)
  server = BaseHTTPServer.HTTPServer(server_address, DemoHandler)
  server.serve_forever()

if __name__ == '__main__':
  open_browser()
  start_server()
