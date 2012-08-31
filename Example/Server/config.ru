require 'bundler'
Bundler.require

class Defaults < Sinatra::Base
  get '/defaults.plist' do
    content_type 'application/x-plist'

    {
      'Greeting' => "Hello, World",
      'Price' => 4.20,
      'FeatureXIsLaunched' => true
    }.to_plist
  end
end

run Defaults
