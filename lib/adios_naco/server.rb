module AdiosNaco

  class Server < Sinatra::Base

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
    
    
  end

end