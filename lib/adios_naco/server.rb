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
      t = Turn.create(
        :game_id  =>  body['game_id'], 
        :player1  =>  body['player'],          # This is wrong because the player
        :action1  =>  body['action'],          # could just as easily have been
        :tick     =>  body['tick']             # player2 instead of player1.
      )
      
      # return HTTP 201 Resource Created status code
      status 201
      
      # returns this in the message body
      { 'game_id'  => t.game_id,
        'player'   => t.player1,
        'action'   => t.action1,
        'tick'     => t.tick.to_i   
       }.to_json
    end
    
  end

end