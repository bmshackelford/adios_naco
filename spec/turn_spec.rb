require 'spec_helper'

include AdiosNaco

describe Turn do
  let(:game){ Game.create(:first_tick=>Time.at(0),
                          :player1=>"Dad",
                          :player2=>"Bea")}
                         

  it "has a game, tick, player1, player2 and action1 and action2" do

    t = Turn.create(
                     :game_id   => game.id,
                     :tick      => game.next_tick,
                     :player1   => "Dad",
                     :player2   => "Bea",
                     :action1   => "load",
                     :action2   => "shield"           
                    )
    expect(t.game).to eq(game) 
    expect(t.tick).to eq( Time.at(game.next_tick))
    expect(t.action1).to eq("load")
    expect(t.action2).to eq("shield")
    expect(t.player1).to eq("Dad")
    expect(t.player2).to eq("Bea")
    
  end
 

  it "raises an error unless we have the tick "do
    expect {
              Turn.create(
                           :tick     => nil,
                           :game_id  => game.id,
                           :player1   => "Dad",
                           :player2   => "Bea",
                           :action1   => "load",
                           :action2   => "shield")
                 
    }.to raise_error(DataMapper::SaveFailureError)
  end

  it "raises an error unless we have a game id" do
    expect {
            Turn.create(
                          :tick     => game.next_tick ,
                          :game_id   =>  nil,
                          :player1   => "Dad",
                          :player2   => "Bea",
                          :action1   => "load",
                          :action2   => "shield")     
      
    }.to raise_error(DataMapper::SaveFailureError)
  end
  
  it "allows you to save player1 without saving player2" do
     expect {
             Turn.create(
                         :game_id   => game.id,
                         :tick      => game.next_tick,
                         :player1   => "Dad",
                         :action1   => "load")         
        
       }.not_to raise_error
  end
  
  it "allows you to save player2 without saving player1" do
       expect {
              Turn.create(         
                         :game_id   => game.id,
                         :tick      => game.next_tick,
                         :player2   => "Bea",
                         :action2   => "shield")         
        
       }.not_to raise_error
  end                               


  it "detects when both players have taken a turn" do
    t = Turn.create(
                     :game_id   => game.id,
                     :tick      => game.next_tick,
                     :player1   => "Dad",
                     :player2   => "Bea",
                     :action1   => "load",
                     :action2   => "shield"           
                    )

     expect(t.complete?).to eq(true)
  end

  it "names the players we are waiting on to take their turn" do
    t = Turn.create(
                     :game_id   => game.id,
                     :tick      => game.next_tick )

   expect( t.yet_to_play ).to eq(['Dad','Bea'])
  end

  describe "rules" do 
    
    it "players cannot change their actions once they've saved a turn" do
      t = Turn.create(
                   :tick     => game.next_tick,
                   :game_id  => game.id,
                   :player1   => "Dad",
                   :action1   => "load")
      
      expect {
        t.action1 =  'shield'       
        t.save          
      }.to raise_error(DataMapper::SaveFailureError)
  
    end
  
    
    it "raises an error when action is something other than load, shoot or shield" do
      expect {
        Turn.create(
                   :tick     => game.next_tick,
                   :game_id  => game.id,
                   :player2   => "Dad",
                   :action2   => "bang")
      }.to raise_error(DataMapper::SaveFailureError)      
    end

    it "kills player if opponent shoots and player does not pick shield" do

      t = Turn.create( :tick     => game.next_tick,
                       :game_id  => game.id,
                       :player1   => "Dad",
                       :action1   => "load")

      t.update(       :player2   => "Bea",
                      :action2   => "shoot")
    
      expect( t.game.dead_player ).to eq("Dad")
      
    end
    
    it "adds a bullet to the player's amo when you load"

    it "shield protects player if oppent shoots"

    it "shoot doesn't kill openent if no bullets remain"

    it "sheild doesn't protect player if used more than three times in a row" 
    
  end
  
end 
