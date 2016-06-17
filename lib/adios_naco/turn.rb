module AdiosNaco  
  class Turn
    include DataMapper::Resource
    property :id,         Serial,    :key => true 
    property :action,     String
    property :player,     String
    property :tick,       EpochTime
  
    belongs_to :game
 
  end 
end
