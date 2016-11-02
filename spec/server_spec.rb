require 'spec_helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

describe AdiosNaco do
  
  include Rack::Test::Methods
  
  def app
    AdiosNaco::Server
  end
  
  it 'has a version number' do
    expect(AdiosNaco::VERSION).not_to be nil
  end

  it 'provides a version end-point' do
    get '/version'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(AdiosNaco::VERSION)
  end
  
  context "game endpoint" do
  
    before :each do
      Game.auto_migrate!
      GameRequest.auto_migrate!
      players = %w{ Dad Helen Beatrice Nathaniel Ava John-Andrew }
      
      3.times do
        Game.create(:player1 => players.shift, 
                    :player2 => players.shift )
      end
      
    end
    
    it 'lists all games' do
      get '/api/games'
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_nil
      
      games = JSON.parse(last_response.body)
      expect(games.size).to eq(3) # all three games
      expect(games[0]['player1']).to eq("Dad")
    end
    
    it 'provides game details' do
      get '/api/games/1'
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_nil

      game = JSON.parse(last_response.body)      
      expect(game['player1']).to eq("Dad")
    end
    
    it 'adds a new game' do

      post('/api/games', { 'player1' => 'Beatrice', 
                           'player2' => 'Dad'}.to_json )

      expect(last_response.status).to eq(201)
      
      # verify that we return the new game when it is created
      new_game = JSON.parse(last_response.body)
      expect(new_game['id']).to eq(4)

      # verify that the database has been updated with the new game
      expect(Game.count).to eq(4)
      expect(Game.last.player1).to eq('Beatrice')
    end
  
  end # game endpoint tests

  context "gameRequest endpoint" do
  
    before :each do
      Game.auto_migrate!
      GameRequest.auto_migrate!
      
      GameRequest.create(:player_name => 'Dad') # Dad is waiting to play
      GameRequest.create(:player_name => 'Nate') # Nate is waiting to play
    end
    
    it "associates the gameRequest with a game if another player is already waiting to play" do
      post('/api/gameRequests', { 'player_name' => 'Beatrice' }.to_json )
      expect(last_response.status).to eq(201)
      
      # verify that a game has been assigned
      r = JSON.parse(last_response.body)
      expect(r['game_id']).not_to be_nil
      
      g = Game.get(r['game_id']) 
      expect(g.player1).to eq('Dad') # because Dad asked to play first
      expect(g.player2).to eq('Beatrice')  
    end
    
    it 'lists all game requests' do
      get '/api/gameRequests'
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_nil
      
      requests = JSON.parse(last_response.body)
      expect(requests.size).to eq(2) # all three game requests
      expect(requests[0]['player_name']).to eq("Dad")
      expect(requests[1]['player_name']).to eq("Nate")
    end
    
    it 'provides game request details' do
      get '/api/gameRequests/1'
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_nil

      requests = JSON.parse(last_response.body)      
      expect(requests['player_name']).to eq("Dad")
    end  
    
  end
  
  context "gameTurn endpoint" do 

    # We'll also need some approach that would prevent players from impersonating another
    # player. Perhaps when a game is returned we give each player their own secret 
    # player-id and require that it is used in future transactions. 
    
    context "after one player takes a turn" do

      before :each do
      
        Game.auto_migrate!
        GameRequest.auto_migrate!
        Turn.auto_migrate!
      
        @game = Game.create(  :player1 => 'Beatrice', 
                              :player2 => 'Dad' )
                                                            
        @tick = @game.last_tick
      
        @turn = { 'game_id'   =>  @game.id,
                  'player'    => 'Dad', 
                  'action'    => 'load',
                  'tick'      => @tick
                }.to_json
      end
    
      it "sends an HTTP status code indicating success" do
        post('/api/gameTurns', @turn)
        expect(last_response.status).to eq(201)
      end
      
      it "returns the submitted turn record" do
        post('/api/gameTurns', @turn)
        responseTurn = JSON.parse(last_response.body)
        expect(responseTurn['player']).to eq('Dad')
        expect(responseTurn['action']).to eq('load')
        expect(responseTurn['tick']).to eq(@tick)
        expect(responseTurn['game_id']).to eq(@game.id)
      end
   
      it "doesn't send a turn result since only one player has acted" do
        post('/api/gameTurns', @turn)
        responseTurn = JSON.parse(last_response.body)
        expect(responseTurn['opponent_action']).to be_nil
      end
      
      it "updates the database with the turn record" do
        post('/api/gameTurns', @turn)
        # Verify that the database has been updated with the new game.
        # Here we specifically check player2 and action2 two because,
        # according to the game, Dad is the second player.        
        expect(Turn.count).to eq(1)
        expect(Turn.last.player2).to eq('Dad')
        expect(Turn.last.action2).to eq('load') 
      end
      
    end 
  
    context "after the second player takes a turn" do
  
      before :each do
        
        Game.auto_migrate!
        GameRequest.auto_migrate!
        Turn.auto_migrate!
        
        @game = Game.create(  :player1 => 'Beatrice', 
                              :player2 => 'Dad' )
        
        # Create first turn in the database
        Turn.create( :tick     => @game.next_tick,
                     :game_id  => @game.id,
                     :player2  => "Dad",
                     :action2  => "load")
        
        # Take a second turn through the server
        @second_turn = { 'game_id'   => @game.id,
                         'tick'      => @game.next_tick,
                         'player'    => 'Beatrice', 
                         'action'    => 'shoot' 
                       }.to_json  
      end
     
      it "sends an HTTP status code indicating success" do
        post('/api/gameTurns', @second_turn)
        expect(last_response.status).to eq(201)
      end
      
      it "returns the submitted turn record" do
        post('/api/gameTurns', @second_turn)
        res = JSON.parse(last_response.body)
        expect(res['player']).to eq('Beatrice')
        expect(res['action']).to eq('shoot')
        expect(res['game_id']).to eq(@game.id)
        expect(res['tick']).to eq(@game.next_tick)
      end
      
      it "send the turn result since both players have acted" do
        post('/api/gameTurns', @second_turn)
        res = JSON.parse(last_response.body)
        expect(res['opponent_action']).to eq('load')
        expect(res['death']).to eq('Dad')
      end
      
      it "updates the database with the turn record" do
        post('/api/gameTurns', @second_turn)
        expect(Turn.count).to eq(1)
        expect(Turn.last.player1).to eq('Beatrice')
        expect(Turn.last.action1).to eq('shoot') 
      end
  
    end
    
  end  
  
  
end
