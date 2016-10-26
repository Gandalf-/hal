import threading, webbrowser
import sys, time, re, os
import BaseHTTPServer, SimpleHTTPServer

from time import strftime, gmtime, sleep
from subprocess import Popen

# globals
FILE = 'index.html'
PORT = 48000

root_dir = '/tmp/hal/demo/'
hal_output_file = root_dir + 'hal_output.log'
hal_input_file = root_dir + 'input.log'

# startup filesystem setup
Popen(['mkdir','-p', root_dir])
Popen(['touch', hal_input_file])
Popen(['touch', hal_output_file])

class DemoHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
  ''' none -> none
  web server class
  '''

  def do_GET(self):
    ''' none -> none
    Handle GET request, only allow variations on index.html and favicon
    '''
    if self.path in ['/', '/index.html', 'http://hal-demo.anardil.net:48000/']:
      self.path = '/index.html'
      self.send_response(200)
      self.send_header('Content-Type', 'text/html')
      self.end_headers()
      self.wfile.write(open(os.curdir + os.sep + self.path).read())
    elif self.path == '/favicon.ico':
      self.send_response(200)
      self.send_header('Content-Type', 'image/x-icon')
      self.end_headers()
      self.wfile.write(open(os.curdir + os.sep + self.path).read())
    else:
      self.send_error(404)

  def do_POST(self):
    ''' none -> none
    Handle a POST request by writing the contents to 
    hal_input_file, waiting a bit, and then returning 
    the contents out of hal_output_file to the request
    '''
    length = int(self.headers.getheader('content-length'))
    data_string = self.rfile.read(length)[:64]
    name, message = data_string.split('%%%')
    data_string = str(
        strftime("[%H:%M:%S]", gmtime()) + 
        ' [Server thread/INFO]: <' + name + '>' + message)
    result = 'error'

    # provide hal user input, hal will pick it up
    with open(hal_input_file, 'a') as in_file:
      in_file.write(data_string + '\n')

    # wait for hal to work
    sleep(0.35)

    # return hal's response to the user, clear output file
    with open(hal_output_file, 'r+') as out_file:
      result = out_file.read()
    open(hal_output_file, 'w').close()

    result = hal_pretty_print(result)
    print "Sending:", result
    self.wfile.write(result)
    return

def hal_pretty_print(result):
  '''string -> string
  Tries to interpret what Minecraft would do with strings
  '''
  lines = result.split('\n')
  out = ''

  for line in lines:
    words = line.split()
    override = False

    if words:
      if words[0] == '/say': words[0] = ''

      # these will never run, so don't hand to hal
      elif words[0] == '/tell':
        override = "[Hal] I'll tell them when they show up again!"

      if override: out += override + '<br>'
      else: out += ' '.join(words) + '<br>'

  # handle html {<,>}'s
  out = re.sub(r'<', "&lt", out)
  out = re.sub(r'>', "&gt", out)
  out = re.sub(r'&ltbr&gt', "<br>", out)
  return out


def open_browser():
  ''' none -> none
  Start a browser after waiting a bit
  '''
  def _open_browser():
    webbrowser.open('http://localhost:%s/%s' % (PORT, FILE))
    thread = threading.Timer(0.5, _open_browser)
    thread.start()

def start_server():
  ''' none -> none
  Start the server
  '''
  print('Starting web server')
  server_address = ("", PORT)
  server = BaseHTTPServer.HTTPServer(server_address, DemoHandler)
  server.serve_forever()

def start_hal():
  ''' none -> none
  Start hal in the background in debug mode
  '''
  print('Starting hal')

  hal = Popen(
      ['bash', '../hal.sh', hal_input_file, '../', root_dir, hal_output_file])
  print('Hal started. PID: ', hal.pid)
  return hal

# main
if __name__ == '__main__':
  try:
    hal = start_hal()
    open_browser()
    start_server()

  except KeyboardInterrupt:
    print('Exiting')
    Popen(['rm', hal_input_file])
    Popen(['rm', hal_output_file])
    hal.kill()
    sys.exit()
