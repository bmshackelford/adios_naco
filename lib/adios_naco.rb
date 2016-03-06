require 'rubygems'
require 'bundler'
require 'sinatra'
require 'data_mapper'
require 'dm-redis-adapter'
require 'dm-timestamps'
require 'json'

$LOAD_PATH.unshift(File.join(__dir__, 'adios_naco'))

require 'version'
require 'game'
require 'game_request'
require 'server'


module AdiosNaco

  Sinatra::Base.configure :development do
    puts "Running Adios Nacos in DEVELOPMENT"  
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
    DataMapper::Logger.new($stdout, :debug) unless defined?(RSpec) 
    DataMapper.finalize
  end
  

  Sinatra::Base.configure :production do 
    puts "Running Adios Nacos in PRODUCTION"      
    DataMapper.setup(:default, {:adapter  => "redis"})
    DataMapper::Logger.new($stdout, :debug)  
    DataMapper.finalize
    
    Redis.current = Redis.new(
                               :host => ENV['REDIS_HOST']           || '127.0.0.1', 
                               :port => ENV['REDIS_PORT'].to_s.to_i || 6379 )    
  end


end
