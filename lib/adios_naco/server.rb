module AdiosNaco

  class Server < Sinatra::Base
    
    set :public_folder, File.expand_path(File.join(__dir__, '..','..','html'))
    
    get '/' do
      send_file File.join(settings.public_folder, 'app.html')  
    end
    
    get '/version' do
      VERSION
    end
    
    # Game Controller
    
    get '/api/games' do
      Game.all.to_json
    end
    
    get '/api/games/:id' do
      g = Game.get(params[:id])
      if g.nil?
        halt 404
      end
      g.to_json
    end
    
    post '/api/games' do
      body = JSON.parse request.body.read
      g = Game.create(body)
      status 201
      g.to_json
    end
    
    # Game Request Controller

    get '/api/gameRequests' do
      GameRequest.all.to_json
    end

    get '/api/gameRequests/:id' do
      g = GameRequest.get(params[:id])
      if g.nil?
        halt 404
      end
      g.to_json
    end
    
    post '/api/gameRequests' do
      body = JSON.parse request.body.read
      r = GameRequest.create(:player_name => body['player_name'])
      r.assign_game!(:retry => 3, :delay => 0.1)
      status 201
      r.to_json
    end
    
    # Game Turn Controller
    
    post '/api/gameTurns' do
      
      body = JSON.parse request.body.read
      
      game = Game.get(body['game_id'])

      
      t = Turn.last(:game_id => body['game_id'], :tick => body['tick'])

      num = 1 if body['player'] ==  game.player1
      num = 2 if body['player'] ==  game.player2
      
      if t.nil? # first player to take a turn
        t = Turn.create(
                          :game_id               =>  body['game_id'], 
                          :tick                  =>  body['tick'],
                          "player#{num}".to_sym  =>  body['player'],         
                          "action#{num}".to_sym  =>  body['action'])

      else # second player to take a turn
        t.update(
                          "player#{num}".to_sym  =>  body['player'],         
                          "action#{num}".to_sym  =>  body['action'])
      end
      
      # return HTTP 201 Resource Created status code
      status 201
      
      # returns this in the message body
      { 'game_id'  => t.game_id,
        'tick'     => t.tick.to_i,   
        'player'   => body['player'], 
        'action'   => body['action']  
       }.to_json
    end
    
  end

end