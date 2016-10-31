require 'spec_helper'

include AdiosNaco

describe Game do

  context "when newly created" do
    
    let(:game){ Game.create(:first_tick=>Time.at(10))}
    # Would be nice if I stub in Time.now, but I'm not sure how to do this
    # outside of an it-block as I don't think it is allowed in before or let block.
     
  	it "includes the server version" do
      expect(game.version).to eq(AdiosNaco::VERSION)
  	end

    it "has the start time" do
      expect(game.first_tick).to eq(Time.at(10))
    end
    
  end
  
  it "has two players" do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    expect(g.player1).to eq("Dad")
    expect(g.player2).to eq("Bea")
  end
  
  it "must have two players" do
    g = Game.create(:player1=>"Dad")
    expect(g.saved?).to eq(false)
  end
  
  it "cannot have the same player twice" do
    g = Game.create(:player1=>"Bea",:player2=>"Bea")
    expect(g.saved?).to eq(false)    
  end
   
  it "calculates the last tick, no more than three seconds ago" do
    game = Game.new
    expect(Time).to receive(:now).and_return(10,11,12)

    expect(game.last_tick).to eq(9)
    expect(game.last_tick).to eq(9)
    expect(game.last_tick).to eq(12)
  end
  
  it "calculates the next tick, no more than three seconds from now" do
    game = Game.new
    expect(Time).to receive(:now).and_return(10,11,12)
        
    expect(game.next_tick).to eq(12)
    expect(game.next_tick).to eq(12)  
    expect(game.next_tick).to eq(15)    
  end
  
  
  it "starts both players with zero bullets" do
    
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    expect(g.player1_bullets).to eq(0)
    expect(g.player2_bullets).to eq(0)
    
  end

  it "can add a bullet for a player" do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    g.load(:player1)
    
    # verify that we saved the result of the load action
    game_id = g.id
    loaded_game = Game.get(game_id)
    
    expect(loaded_game.player1_bullets).to eq(1)
    expect(loaded_game.player2_bullets).to eq(0)
  end  
    
  it "can remove a bullet for a player" do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    g.player1_bullets = 3
    g.player2_bullets = 3
    g.save
    g.fire_bullet(:player1)
    
    # verify that we saved the result of the fire action
    game_id = g.id
    loaded_game = Game.get(game_id)
  
    expect(loaded_game.player1_bullets).to eq(2)
    expect(loaded_game.player2_bullets).to eq(3)
  end
  
  
  it "starts both players with zero shields" do
    
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    expect(g.player1_shields).to eq(0)
    expect(g.player2_shields).to eq(0)
  end
  
  
  it "tracks number of shields used"do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    g.use_shield(:player1)
  
    # verify that we saved the result of the load action
    game_id = g.id
    loaded_game = Game.get(game_id)
  
    expect(loaded_game.player1_shields).to eq(1)
    expect(loaded_game.player2_shields).to eq(0)
  end  
      
  it "resets shield use to zero" do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    g.player1_shields = 2
    g.player2_shields = 2
    g.save
    
    g.reset_shield(:player1)
    
    # verify that we saved the result of the fire action
    game_id = g.id
    loaded_game = Game.get(game_id)
  
    expect(loaded_game.player1_shields).to eq(0)
    expect(loaded_game.player2_shields).to eq(2)
  end
  
  it "records which player is killed" do
    g = Game.create(:player1=>"Dad",:player2=>"Bea")
    g.kill_player(:player1)
    # verify that we saved the result of the fire action
    game_id = g.id
    loaded_game = Game.get(game_id)
    expect(loaded_game.dead_player).to eq("player1")
  end
  

end
