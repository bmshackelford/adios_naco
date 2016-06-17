require 'spec_helper'

include AdiosNaco

describe Turn do
 let(:game){ Game.create(:first_tick=>Time.at(0),
                         :player1=>"Dad",
                         :player2=>"Bea")}

  it "has a game, tick, player and action" do

   t = Turn.create(:action   => "load",
                   :game_id  => game.id,
                   :player   => "Dad",
                   :tick     => game.next_tick )
   
    expect(t.action).to eq("load")
    expect(t.game).to eq(game) 
    expect(t.player).to eq("Dad")
    expect(t.tick).to eq( Time.at(game.next_tick))
 end


  it "must have an action" 
  it "must have the tick "
  it "must have a game id"
  it "must have a player id"
end 
      
      