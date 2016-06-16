module AdiosNaco

  class Game

    include DataMapper::Resource
    
    property :id,         Serial,    :key => true
    property :first_tick, EpochTime, :default => lambda{|r,p| Time.at(r.next_tick) }
    property :version,    String,    :default => lambda{|r,p| AdiosNaco::VERSION }
    property :player1,    String
    property :player2,    String
    
    has n, :game_requests
    has n, :rounds
   
    validates_presence_of :player1, :player2
    
    validates_with_block do
      @player1 != @player2   
    end
    
    def last_tick
      (Time.now.to_i/3.0).floor * 3
    end
    
    def next_tick
      last_tick + 3
    end
    
    def to_s
      "<#{self.class} #{self.id} #{self.player1} vs #{self.player2}>"
    end
    
  end

end
