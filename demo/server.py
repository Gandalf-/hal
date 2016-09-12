import threading, webbrowser, subprocess
import sys, time, re, os
import BaseHTTPServer, SimpleHTTPServer

FILE = 'index.html'
PORT = 8000

root_dir = '/tmp/hal/demo/'
hal_output_file = root_dir + 'hal_output.log'
hal_input_file = root_dir + 'input.log'

subprocess.Popen(['mkdir','-p', root_dir])
subprocess.Popen(['touch', hal_input_file])
subprocess.Popen(['touch', hal_output_file])


class DemoHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
  '''The dynamic part, maybe'''

  def do_GET(self):
    if self.path == "/" or self.path == "/index.html":
      self.path = "/index.html"
      self.send_response(200)
      self.send_header('Content-Type', 'text/html')
      self.end_headers()
      self.wfile.write(open(os.curdir + os.sep + self.path).read())
    else:
      self.send_error(404)

  def do_POST(self):
    '''Handle a post request by returning the square'''
    length = int(self.headers.getheader('content-length'))
    data_string = self.rfile.read(length)
    data_string = data_string[:64]
    data_string = str(time.strftime("[%H:%M:%S]", time.gmtime()) + ' [Server thread/INFO]: <Steve>' + data_string)
    result = 'error'

    # provide hal user input, hal will pick it up
    with open(hal_input_file, 'a') as in_file:
      in_file.write(data_string + '\n')

    # wait for hal to work
    time.sleep(0.3)

    # return hal's response to the user, clear output file
    with open(hal_output_file, 'r+') as out_file:
      result = out_file.read()
    open(hal_output_file, 'w').close()

    result = hal_pretty_print(result)
    print "Sending:", result
    self.wfile.write(result)
    return

def hal_pretty_print(result):
  '''Tries to interpret what Minecraft would do with strings'''
  lines = result.split('\n')
  out = ''

  for line in lines:
    words = line.split()

    if words:
      override = False

      if words[0] == '/say':
        words[0] = ''

      elif words[0] == '/tell':
        override = "[Hal] I'll tell them when they show up again!"

      if override: out += override + '<br>'
      else: out += ' '.join(words) + '<br>'

  out = re.sub(r'<', "&lt", out)
  out = re.sub(r'>', "&gt", out)
  out = re.sub(r'&ltbr&gt', "<br>", out)
  return out


def open_browser():
  '''Start a browser after waiting a bit'''
  def _open_browser():
    webbrowser.open('http://localhost:%s/%s' % (PORT, FILE))
    thread = threading.Timer(0.5, _open_browser)
    thread.start()

def start_server():
  '''Start the server'''
  print('Starting web server')
  server_address = ("", PORT)
  server = BaseHTTPServer.HTTPServer(server_address, DemoHandler)
  server.serve_forever()

def start_hal():
  '''Start hal'''
  print('Starting hal')

  hal = subprocess.Popen(
      ['bash', '../hal.sh', hal_input_file, '../', root_dir, hal_output_file])
  print('Hal started. PID: ', hal.pid)
  return hal

if __name__ == '__main__':
  try:
    hal = start_hal()
    open_browser()
    start_server()

  except KeyboardInterrupt:
    print('Exiting')
    subprocess.Popen(['rm', hal_input_file])
    subprocess.Popen(['rm', hal_output_file])
    hal.kill()
    sys.exit()
