require 'pry'

class ThreadPool
  def initialize()
    @threads = []
  end

  def add_block(&block)
    @threads << Thread.new { block.call() }
  end

  def join_threades
    @threads.each do |thr|
      begin
        thr.join
      rescue => e
        puts "Failed: #{e.message}"
      end
    end
  end
end
