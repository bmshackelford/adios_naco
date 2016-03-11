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
        sleep delay * (n^2) unless n == attempts
      end
      
      return assignment_results  
    end
    
    def to_s
      "<#{self.class} #{self.id} for #{self.player_name}, game: #{self.game_id}>"
    end
    
    private
    
    def attempt_game_assignment!
      
      reqs = GameRequest.all( :order      => :created_at,
                              :limit      => 1, 
                              :conditions =>{ :game_id         => nil, 
                                              :player_name.not => self.player_name, 
                                              :id.not          => self.id })
                                             
      if reqs.size == 1
        g = Game.create(:player1 => reqs.first.player_name , :player2 => player_name)
        $stderr.puts "EXPECTING TO START GAME #{g.id}"
        if g.saved? && reqs.update(:game_id => g.id)
          self.game_id = g.id
          self.save
          $stderr.puts "#{self.player_name } JOINED A GAME with #{g.player1}"
          return true
        else
          # The other player who was going to join us,
          # joined another game instead. Delete the game and give up.
          $stderr.puts "#{self.player_name } COULD NOT JOIN A GAME"
          $stederr.puts "Unexpected problem saving #{g.inspect}" unless g.saved?
          g.destroy if g.saved?
          return false
        end
      else # We didn't find anyone to join the game.
        $stderr.puts "NO ONE WANTS TO PLAY JUST NOW."
        return false
      end
    end
  
  end # GameRequest
  
end # Adios Naco
