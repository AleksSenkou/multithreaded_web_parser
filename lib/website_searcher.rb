require 'csv'
require 'postrank-uri'
require 'open-uri'
require 'open_uri_redirections'
require 'active_support/inflector'
require_relative 'thread_pool'
require_relative 'messages'

include Messages

class WebsiteSearcher
  attr_reader :urls

  def initialize(urls_file = '../text/urls.txt', search_pattern = 'text')
    @urls_file = urls_file
    @search_pattern = search_pattern
    @urls = []
    @threads = []
    @results = {}
    @thread_pool = ThreadPool.new 20

    get_urls_from_file
  end

  def run
    @urls.each do |url|
      @thread_pool.add_block do
        start_fetch_msg url

        match_count, output = get_result_from url
        add_result url, match_count, output

        finish_fetch_msg url
      end
    end

    @thread_pool.join_threades
  end

  def save_results_to(filename = '../text/results.txt')
    File.open(filename, 'w') do |file|
      file.write @results.to_yaml
    end
  end

  private

  def get_result_from(url)
    fetched_data = fetch_data_from url
    match_count = count_matches fetched_data
    user_friendly_output = generate_output match_count

    [match_count, user_friendly_output]
  end

  def get_urls_from_file
    urls_dirty_list = CSV.read(@urls_file, headers: true)['URL']
    @urls = PostRank::URI.extract urls_dirty_list
  end

  def fetch_data_from(url)
    open(url, allow_redirections: :safe).read
  end

  def count_matches(data)
    data.scan(/\b#{ @search_pattern }\b/i).size
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
