require 'spec_helper'

include AdiosNaco

describe GameRequest do
  
  before :each do
    GameRequest.auto_migrate!
    Game.auto_migrate!
  end
  
  it "knows players name" do
    g = GameRequest.create( :player_name => 'Rey')
    expect(g.id).to eq(1) # If relationships are not properly defined as optional
                          # we will not be able to save the record and we will
                          # get a nil for the ID.
    
    saved_game = GameRequest.get(g.id)
    expect(saved_game).to be_kind_of(GameRequest)
    
    expect(saved_game.player_name).to eq('Rey')
  end
  
  it "can have a game" do
   r = GameRequest.create( :player_name => 'Rey')
   r.game=Game.create(:player1 => 'Bea', :player2 => 'Dad')
   r.save
   expect(GameRequest.get(r.id).game).to be_kind_of(Game)
  end
  
  
  it "can assign a game to a request when at least one other player is waiting" do

    # Two players are queued to play
    r1 = GameRequest.create( :player_name => 'Dad')
    r2 = GameRequest.create( :player_name => 'Beatrice')

    # A new player wants to join
    r3 = GameRequest.create( :player_name => 'Nate')
    
    # We assign a game
    expect(r3.assign_game!).to be true
    expect(r3.game_id).not_to be_nil

    # We match with the earliest request
    expect(r1.reload.game_id).to eq(r3.game_id)
  end
  
  it "doesn't assign a game if no players are in the queue" do
    r1 = GameRequest.create( :player_name => 'Beatrice')
    expect(r1.assign_game!).to be false
    expect(r1.reload.game_id).to be nil
  end
  
  it "doesn't assign a game if another player is waiting but joins a different game" do
    # This test exists to demonstrate that our logic is robust against race conditions

    # One player is queued to play
    r1 = GameRequest.create( :player_name => 'Dad')

    # A new player wants to join
    r2 = GameRequest.create( :player_name => 'Nate')
    
    # We attempt to assign a game just as the other player
    # is being assigned to a different game (race condition)
    original_all = GameRequest.method(:all)
    allow(GameRequest).to receive(:all).once do |*args| 
      all = original_all.call(*args)  # orginal call
      # simulate race condition
      game = Game.create(:player1 => 'Dad', :player2 => 'Mom')
      original_all.call(*args).update(:game => game )
      # return
      all
    end
    
    # Given the race condition we couldn't assign the game.
    expect(r2.assign_game!).to be false
    expect(r2.game_id).to be_nil
    expect(Game.all.count).to eq(1) # In other words, we don't have any extra dangling games.
  end
  
  it "can repeat the assignment attempt until successful" do
    # Start with no players queued, and one user requesting
    r1 = GameRequest.create( :player_name => 'Helen')
    expect(r1).to receive(:attempt_game_assignment!).and_return(false,false,true).exactly(3).times  
    expect(r1.assign_game!(:retry => 4, :delay => 0)).to eq(true)
  end
  
  it "can repeat the assignment attempt until attempts run out" do
    # Start with no players queued, and one user requesting
    r1 = GameRequest.create( :player_name => 'Helen')
    expect(r1).to receive(:attempt_game_assignment!).and_return(false).exactly(4).times
    expect(r1.assign_game!(:retry => 4, :delay => 0)).to eq(false)
  end
  
end
