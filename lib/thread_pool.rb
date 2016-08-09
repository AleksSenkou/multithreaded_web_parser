require 'pry'

class ThreadPool
  include Messages

  def initialize(threads_limit = 20)
    @threads_limit = threads_limit
    @blocks = Queue.new

    @threads = Array.new(threads_limit) do |index|
      Thread.new do
        Thread.current[:index] = index
        catch(:exit) do
          loop { @blocks.pop.call() }
        end
      end
    end
  end

  def add_block(&block)
    @blocks << block
  end

  def join_threades
    @threads_limit.times do
      add_block { throw :exit }
    end

    @threads.each do |thread|
      begin
        thread.join
      rescue => e
        puts "Failed: #{e.message}"
      end
    end
  end
end
