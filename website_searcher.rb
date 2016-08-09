require 'pry'
require 'concurrent'
require 'csv'
require 'postrank-uri'
require 'open-uri'
require 'open_uri_redirections'
require 'active_support/inflector'

class WebsiteSearcher
  attr_reader :urls

  def initialize(file_with_urls_info = 'urls.txt', data_for_search = /text/)
    @urls_file = file_with_urls_info
    @data_for_search = data_for_search
    @urls = []
    @results = {}

    get_urls_from_file
  end

  def fetch_data
    @urls.each_with_index do |url, number|
      fetched_data = open(url, allow_redirections: :safe).read
      match_count = (fetched_data =~ @data_for_search).to_i
      result = "Found #{match_count} #{'match'.pluralize(match_count)}"

      @results[url] = {
        number: number + 1,
        match_count: match_count,
        result: result
      }
    end
  end

  def save_results
    File.open('results.txt', 'w') do |file|
      file.write @results.to_yaml
    end
  end

  private

  def get_urls_from_file
    # add checks
    urls_dirty_list = CSV.read(@urls_file, headers: true)['URL']
    @urls = PostRank::URI.extract urls_dirty_list
  end
end

searcher = WebsiteSearcher.new
searcher.fetch_data
searcher.save_results

# pool = Concurrent::ThreadPoolExecutor.new(
#   min_threads: 1,
#   max_threads: 20,
#   max_queue: 10
# )
