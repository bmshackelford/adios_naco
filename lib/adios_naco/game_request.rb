module AdiosNaco

  class GameRequest
    
    include DataMapper::Resource
    
    property :id,           Serial,  :key => true
    property :player_name,  String 
    
    property :created_at,   DateTime
    property :updated_at,   DateTime
    
    belongs_to :game, :required => false

    def assign_game!(*args)
      attempts = 1
      delay    = 0.2
      
      if args.first.kind_of?(Hash)
        attempts = args.first[:retry].to_i || attempts
        delay    = args.first[:delay].to_f || delay         
      end
      
      assignment_results = false
      
      attempts.times do |n|
        assignment_results = attempt_game_assignment!
        break if assignment_results
        sleep delay * (n^2)
      end
      
      return assignment_results  
    end
    
    private
    
    def attempt_game_assignment!
      reqs = GameRequest.all(:order=>:created_at,:conditions =>{:game=>nil, :id.not => self.id },:limit=>1)
      if reqs.size == 1
        g = Game.create(:player1 => reqs.first.player_name , :player2 => player_name)
        if reqs.update(:game => g)
          self.game = g
          self.save
          return true
        else
          # The other player who was going to join us,
          # joined another game instead. Delete the game and give up.
          g.destroy
          return false
        end
      else # We didn't find anyone to join the game.
        return false
      end
    end

  end # GameRequest
  
end # Adios Naco
