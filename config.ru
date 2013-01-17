require 'rubygems'
require 'sinatra'
require './app'

set :environment, :production

run Sinatra::Application