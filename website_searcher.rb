require 'pry'
require 'csv'
require 'postrank-uri'
require 'open-uri'
require 'open_uri_redirections'
require 'active_support/inflector'
# require './thread_pool.rb'

class WebsiteSearcher
  attr_reader :urls

  def initialize(file_with_urls_info = 'urls.txt', data_for_search = 'text')
    @urls_file = file_with_urls_info
    @data_for_search = data_for_search
    @urls = []
    @threads = []
    @results = {}

    get_urls_from_file
  end

  def run
    @urls.each do |url|
      @threads << Thread.new(url) do |page|
        puts "Start #{page}"

        fetched_data = fetch_data_from page
        match_count = count_matches fetched_data
        user_friendly_output = generate_output match_count

        add_result(page, match_count, user_friendly_output)

        puts "Finish #{page}"
      end
    end

    join_threades
  end

  def save_results
    File.open('results.txt', 'w') do |file|
      file.write @results.to_yaml
    end
  end

  private

  def join_threades
    @threads.each do |thr|
      begin
        thr.join
      rescue RuntimeError, SocketError, OpenURI::HTTPError => e
        puts "Failed: #{e.message}"
      end
    end
  end

  def get_urls_from_file
    urls_dirty_list = CSV.read(@urls_file, headers: true)['URL']
    @urls = PostRank::URI.extract urls_dirty_list
  end

  def fetch_data_from(url)
    open(url, allow_redirections: :safe).read
  end

  def count_matches(data)
    data.scan(/\b#{ @data_for_search }\b/i).size
  end

  def generate_output(match_count)
    "Found #{match_count} #{'match'.pluralize(match_count)}"
  end

  def add_result(url, match_count, user_friendly_output)
    @results[url] = {
      match_count: match_count,
      user_friendly_output: user_friendly_output
    }
  end
end

searcher = WebsiteSearcher.new
searcher.run
searcher.save_results
