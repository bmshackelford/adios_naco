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


  it "raises an error unless we have an action" do 
  
    expect {
        Turn.create(:action   => nil,
                    :game_id  => game.id,
                    :player   => "Dad",
                    :tick     => game.next_tick )
    }.to raise_error(DataMapper::SaveFailureError)
  end
  
  it "raises an error unless we have the tick "do
   expect {
         Turn.create:action   => "load",
                  :game_id  => game.id,
                  :player   => "Dad",
                  :tick     => nil 
   }.to raise_error(DataMapper::SaveFailureError)
 end

  it "raises an error unless we have a game id" do
 expect {
       Turn.create(:action   => "load",
                   :game_id  => nil,
                   :player   => "Dad",
                   :tick     => game.next_tick )
    }.to raise_error(DataMapper::SaveFailureError)
  end
                                  
  it "raises an error unless we have a player id" do
  expect {
       t = Turn.create(:action   => "load",
                     :game_id  => game.id,
                     :player   => nil,
                     :tick     => game.next_tick )
  }.to raise_error(DataMapper::SaveFailureError)
  end
end 
      
      