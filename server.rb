require 'rack'
require 'pry'
require 'pry-nav'
require 'socket'

class MyServer
  STATUS_CODES = {200 => 'OK', 500 => 'Internal Server Error'}

  attr_reader :app, :tcp_server, :port

  def initialize(app, port = 3000)
    @app = app
    @port = port
  end

  def start
    puts "Booting up Homegrown Webserver"
    puts "Webserver is listening on port #{port}"
    @tcp_server = TCPServer.new('localhost', port)

    loop do
      socket   = tcp_server.accept
      request  = socket.gets
      rest = []
      stuff = ""
      until stuff == "\r\n"
        stuff = socket.gets
        rest << stuff unless stuff == "\r\n"
      end
      puts ""
      puts "Here's what I got from your request"
      puts "#{request}"
      puts rest.join
      response = ''
      env = new_env(*request.split)
      puts ""
      puts "The Rack Env is #{env}"
      status, headers, body = app.call(env)
# binding.pry
      response << "HTTP/1.1 #{status} #{STATUS_CODES[status]}\r\n"
      headers.each do |k, v|
        response << "#{k}: #{v}\r\n"
      end
      # response << "Connection: close\r\n"

      socket.print response
      socket.print "\r\n"

      if body.is_a?(String)
        socket.print body
      else
        body.each do |chunk|
          socket.print chunk
        end
      end
      socket.print "Connection: close\r\n"
      socket.close
    end
  end

  def new_env(method, location, *args)
    {
      'REQUEST_METHOD'   => method,
      'SCRIPT_NAME'      => '',
      'PATH_INFO'        => location,
      'QUERY_STRING'     => parse_params(location),
      'SERVER_NAME'      => 'localhost',
      'SERVER_PORT'      => port.to_s,
      'rack.version'     => Rack.version.split('.'),
      'rack.url_scheme'  => 'http',
      'rack.input'       => StringIO.new(''),
      'rack.errors'      => StringIO.new(''),
      'rack.multithread' => false,
      'rack.run_once'    => false
    }
  end

  
  def parse_params(location)
    query_string = location.split('?').last
    if query_string == "/"
      nil
    else
      Rack::Utils.parse_nested_query(query_string)
    end
  end
end

module Rack
  module Handler
    class MyServer
      def self.run(app, options = {})
        server = ::MyServer.new(app)
        server.start
      end
    end
  end
end
Rack::Handler.register('my_server', 'Rack::Handler::MyServer')