module AdiosNaco

  class Game

    include DataMapper::Resource
    
    property :id,         Serial,    :key => true
    property :first_tick, EpochTime, :default => lambda{|r,p| Time.at(r.next_tick) }
    property :version,    String,    :default => lambda{|r,p| AdiosNaco::VERSION }
    property :player1,    String
    property :player2,    String
    property :player1_bullets,    Integer,  :default => 0   
    property :player2_bullets,    Integer,  :default => 0  
    property :player1_shields,    Integer,  :default => 0  
    property :player2_shields,    Integer,  :default => 0 
    property :dead_player,        String
    has n, :game_requests
    
    
   
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
    
    def load(player)
      self.player1_bullets += 1  if player == :player1
      self.player2_bullets += 1  if player == :player2
      self.save!
      puts "-> #{player} loaded \n#{self.inspect}"
    end
 
    def fire_bullet(player)
      self.player1_bullets -= 1  if player == :player1
      self.player2_bullets -= 1  if player == :player2
      self.save!
    end
    
    def use_shield(player)
      self.player1_shields += 1  if player == :player1
      self.player2_shields += 1  if player == :player2
      self.save!
    end
    
    def reset_shield(player)
      self.player1_shields = 0  if player == :player1
      self.player2_shields = 0  if player == :player2
      self.save!
    end
    
    def kill_player(player)
      self.dead_player = player
      self.save! 
    end
    
    def to_s
      "<#{self.class} #{self.id} #{self.player1} vs #{self.player2}>"
    end
    
  end

  # Game.raise_on_save_failure = true

end
