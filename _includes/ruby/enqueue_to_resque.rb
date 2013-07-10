require 'multi_json'

module MicroAwesomeService
  module Queue
    extend self

    def redis
      MicroAwesomeService.redis
    end

    def encode(object)
      if MultiJson.respond_to?(:dump) && MultiJson.respond_to?(:load)
        MultiJson.dump object
      else
        MultiJson.encode object
      end
    end

    def add(queue, klass_name, *args)
      push(queue, class: klass_name, args: args)
    end

    def push(queue, item)
      watch_queue(queue)
      redis.rpush("resque:queue:#{queue}", encode(item))
    end

    def watch_queue(queue)
      redis.sadd("resque:queues", queue.to_s)
    end
  end
end
