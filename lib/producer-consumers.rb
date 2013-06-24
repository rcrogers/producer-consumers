require 'thread'
class ProducerConsumers
  DONE = Object.new

  def self.run(enumerable, opts = {}, &block)
    self.new(enumerable, opts).run!(&block)
  end

  def initialize(enumerable, opts = {})
    opts = {
      :size => 100,
      :thread_count => 8,
    }.merge opts
    [:size, :thread_count, :begin, :end].each{|s| self.instance_variable_set "@#{s}", opts[s]}
    @enum = enumerable.to_enum
  end

  def run!
    @enum.rewind
    queue = SizedQueue.new @size
    dead_threads = Queue.new

    producer = self.new_thread_with_morgue dead_threads do
      loop do
        begin
          x = @enum.next
        rescue StopIteration
          queue << DONE
          Thread.exit
        end
        queue << x
      end # loop
    end # thread

    consumers = @thread_count.times.map do
      self.new_thread_with_morgue dead_threads do
        @begin and @begin.call
        loop do
          x = queue.shift
          if x == DONE
            queue << DONE
            break
          else
            yield x
          end
        end # loop
        @end and @end.call
      end # thread
    end

    threads = consumers.unshift producer
    live_thread_count = threads.size
    until live_thread_count == 0 do # join all worker threads as soon as they finish
      dead_threads.shift.join
      live_thread_count -= 1
    end
  end

  def new_thread_with_morgue(queue)
    Thread.new do
      begin
        yield
      ensure
        queue << Thread.current
      end
    end
  end

end
