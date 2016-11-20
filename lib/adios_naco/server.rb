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

      if body['player'] ==  game.player1
        current_player  = :player1
        current_action  = :action1
        opponent_player = :player2
        opponent_action = :action2
      end 
     
       if body['player'] ==  game.player2
        current_player  = :player2
        current_action  = :action2
        opponent_player = :player1
        opponent_action = :action1
      end 
    
      if t.nil? # first player to take a turn
        t = Turn.create(
                          :game_id        =>  body['game_id'], 
                          :tick           =>  body['tick'],
                          current_player  =>  body['player'],         
                          current_action  =>  body['action'])

      else # second player to take a turn
        t.update(
                          current_player  =>  body['player'],         
                          current_action  =>  body['action'])
      end
      
      # return HTTP 201 Resource Created status code
      status 201
      
      # returns this in the message body
      turn_response = { 'game_id'  => t.game_id,
                        'tick'     => t.tick.to_i,   
                        'player'   => body['player'], 
                        'action'   => body['action'] } 
      if t.action1 && t.action2
        turn_response.merge!({ 
                        'opponent_action' => t[opponent_action]
        })
      end

      if game.reload && game.dead_player
         turn_response.merge!({ 
                        'death' => game.dead_player
        })
      end
      puts turn_response.to_json
      turn_response.to_json
    end
    
  end

end