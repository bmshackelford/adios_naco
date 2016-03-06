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
  
end
