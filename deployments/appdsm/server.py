#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    filename='appdsm/server.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Set the port
PORT = 8000

# Change to the appdsm directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        logging.info("%s - - [%s] %s" % (
            self.address_string(),
            self.log_date_time_string(),
            format % args
        ))

    def do_GET(self):
        # Log the request
        logging.info(f"GET request for {self.path}")
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

try:
    # Create the server
    with socketserver.TCPServer(("", PORT), MyHttpRequestHandler) as httpd:
        logging.info(f"Server started at {datetime.now()}")
        logging.info(f"Serving at port {PORT}")
        print(f"Server started at http://localhost:{PORT}")
        print("Press Ctrl+C to stop the server")
        
        # Start the server
        httpd.serve_forever()
except KeyboardInterrupt:
    logging.info("Server stopped by user")
    print("\nServer stopped")
except Exception as e:
    logging.error(f"Server error: {str(e)}")
    print(f"Error: {str(e)}")
    sys.exit(1) 