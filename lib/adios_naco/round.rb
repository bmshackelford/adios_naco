module AdiosNaco

  class Round
    include DataMapper::Resource
    
    property :id,         Serial,    :key => true   
  
  end
 end
