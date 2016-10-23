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
  
    before :each do
      
      Game.auto_migrate!
      GameRequest.auto_migrate!
      Turn.auto_migrate!
      
      @game = Game.create(  :player1 => 'Beatrice', 
                            :player2 => 'Dad' )

    end
    
    it "saves turns" do
      
      # Note that we are just starting representing turns and we have to change our approach.
      # We either need Turn to represent actions of both players or we need gameTurn to deal
      # turn records for each player. We'll also need some approach that would prevent
      # players from impersonating another player. Perhaps when a game is returned we give 
      # each player their own secret player-id and require that it is used in future
      # transactions. 
      
      tick = @game.last_tick
      
      post('/api/gameTurns', { 'game_id'         =>  @game.id,
                               'player1_name'    => 'Beatrice', 
                               'player1_action'  => 'LOAD',
                               'tick'            => tick
                              }.to_json )

      expect(last_response.status).to eq(201)
      
      # verify that we return the new game when it is created
      gameTurn = JSON.parse(last_response.body)
      expect(gameTurn['player1_name']).to eq('Beatrice')
      expect(gameTurn['player1_action']).to eq('LOAD')
      expect(gameTurn['tick']).to eq(tick)
      expect(gameTurn['game_id']).to eq(@game.id)
      
      # verify that the database has been updated with the new game
      expect(Turn.count).to eq(1)
      expect(Turn.last.player).to eq('Beatrice')
    end
    
    
    
  end
  
  
end
