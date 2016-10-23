module AdiosNaco  
  class Turn
    include DataMapper::Resource
    
    property :id,         Serial,    :key => true 
    property :action,     String,    :required => true
    property :player,     String,    :required => true      
    property :tick,       EpochTime, :required => true 
  
    belongs_to :game
 
  end
  
  Turn.raise_on_save_failure = true
    
end
