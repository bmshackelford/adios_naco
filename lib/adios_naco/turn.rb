module AdiosNaco  
  class Turn
    include DataMapper::Resource
    
    property :id,         Serial,    :key => true 
    property :tick,       EpochTime, :required => true 
  
    belongs_to :game
    
    property :action1,     String,    :required => false
    property :action2,     String,    :required => false
    property :player1,     String,    :required => false     
    property :player2,     String,    :required => false

    validates_acceptance_of :action1, :action2, :accept => ["load","shoot","shield"]

    validates_with_method :action1, :action2,
                          :method => :first_attempt?
   
    # process turn events
    before :save, :handle_turn
    
  end
  
  Turn.raise_on_save_failure = true
  
  # This is where the bulk of the logic for handling the game rules lives.
  def handle_turn
    # puts "==> Handling turn #{@id} for game #{game.id}\n#{@player1}: #{@action1} vs #{@player2}: #{@action2}"
    if complete?
            
      game.update(:dead_player => @player2) if @action1 == "shoot" && @action2 != "shield"
      game.update(:dead_player => @player1) if @action2 == "shoot" && @action1 != "shield"         
 
      game.load(:player1) if @action1 == "load"
      game.load(:player2) if @action2 == "load"

    end
    # puts "==> Resolved turn #{@id} for game #{game.id}\n#{game.inspect}\n\n"
  end
  
  def first_attempt?

    # get old values for convenience
    old_action1 = original_attributes[Turn.properties[:action1]]
    old_action2 = original_attributes[Turn.properties[:action2]]

    # if no old value is set, we know it is the first attempt
    if old_action1.nil? && old_action2.nil?
      return true
      
    else # since we have an old value, we know one of the players 
         # attempted to change their action
    
         return [false, "Players may not change an action once " +
                        "they've selected one for the turn."]
    end
  end
    
  def complete?
    if @action1.to_s.empty? || 
       @action2.to_s.empty? 
      return false
    else
      return true
    end
  end
    
  def yet_to_play    
    # Start with a list of the players who need to take a turn.
    # We know who these are by looking at the game.
    players = []
    players << self.game.player1
    players << self.game.player2
    
    # We aren't waiting on players who have already acted.
    players.delete(self.game.player1) if ! self.action1.to_s.empty? 
    players.delete(self.game.player2) if ! self.action2.to_s.empty? 

    # return the players who are left -- those who haven't acted yet.
    return players
 end


   
end
