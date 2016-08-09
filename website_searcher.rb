require 'pry'

class WebsiteSearcher
  def initialize(file_with_urls_info = 'urls.txt')
    @urls = file_with_urls_info
  end
end

searcher = WebsiteSearcher.new('urls.txt')
