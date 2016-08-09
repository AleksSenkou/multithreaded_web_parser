require 'pry'
require 'concurrent'
require 'open-uri'
require 'csv'

class WebsiteSearcher
  attr_reader :urls

  def initialize(file_with_urls_info = 'urls.txt')
    @urls_file = file_with_urls_info
  end

  def get_urls_from_file
    # add check
    @urls = CSV.read(@urls_file, headers: true)['URL']
  end
end

searcher = WebsiteSearcher.new
searcher.get_urls_from_file

pool = Concurrent::ThreadPoolExecutor.new(
  min_threads: 1,
  max_threads: 20,
  max_queue: 10
)
