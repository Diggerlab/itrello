require 'sinatra'
require 'slim'
require 'coffee-script'

configure :production, :development do
  enable :logging
end

get '/' do
  slim :main
end

get '/main.js' do 
	content_type "text/javascript"
  coffee :main
end