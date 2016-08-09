require_relative "lib/website_searcher"

urls_file = 'text/urls.txt'
results_file = 'text/results.txt'
search_pattern = 'text'

searcher = WebsiteSearcher.new urls_file, search_pattern
searcher.run
searcher.save_results_to results_file
