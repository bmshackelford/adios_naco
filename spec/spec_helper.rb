$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'adios_naco'
require 'dm-migrations'

include AdiosNaco

RSpec.configure do |config|
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
  DataMapper.finalize
  Game.auto_migrate!
  GameRequest.auto_migrate!
  Turn.auto_migrate!
  
end
