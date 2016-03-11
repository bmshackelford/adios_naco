#
#  Patch to dm-redis-adapter (0.10.1)
#
#  This is required because the read method fails to properly
#  typecast Serial keys which in turn causes dm-core's Model#load
#  to make objects immutable during an update query on a resource 
#  collection previously returned from a query because Model#load 
#  attempts to determine whether the the key for a resource is
#  valid before putting it into the repository's identity map 
#  and it instead finds it invalid because it expects the Serial key
#  to be an Integer and instead finds it to be a String.

module DataMapper
  module Adapters
    class RedisAdapter 
      
      ##
      # Looks up one record or a collection of records from the data-store:
      # "SELECT" in SQL.
      #
      # @param [Query] query
      #   The query to be used to seach for the resources
      #
      # @return [Array]
      #   An Array of Hashes containing the key-value pairs for
      #   each record
      #
      # @api semipublic
      def read(query)
        storage_name = query.model.storage_name
        records = records_for(query)
        records.each do |record|
          record_data = @redis.hgetall("#{storage_name}:#{record[redis_key_for(query.model)]}")

          query.fields.each do |property|
            
            name = property.name.to_s            
            value = if query.model.key.include?(property) and query.model.key.size == 1
              record[name]
            else
              record_data[name]  
            end

            # Integers are stored as Strings in Redis. If there's a
            # string coming out that should be an integer, convert it
            # now. All other typecasting is handled by datamapper
            # separately.
              
            record[name] = [Integer, Date].include?(property.primitive) ? property.typecast( value ) : value
            record
          end
        end
        query.filter_records(records)
      end
      
    end
  end
end

$stderr.puts "Patched--> RedisAdapter"