require 'sinatra'
require_relative "handler"
# my_server is the server I want to write
set :server, :my_server

get '/' do
  "<h1>Hello</h1>"
end