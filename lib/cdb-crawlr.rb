require 'nokogiri'
require 'typhoeus'
require 'uri'

$:.unshift(File.dirname(__FILE__))

require 'cdb/struct'
require 'cdb/title'

module CDB
  VERSION = '0.0.1'

  BASE_URL = 'http://www.comicbookdb.com'
  REQUEST_HEADERS = {'Connection' => 'keep-alive'}
  SEARCH_PATH = 'search.php'

  class << self; attr

    def search(searchtype, query)
      data = URI.encode_www_form(
        form_searchtype: searchtype,
        form_search: query
      )
      url = "#{BASE_URL}/#{SEARCH_PATH}?#{data}"
      resp = Typhoeus::Request.get(url, :headers => REQUEST_HEADERS)
      node = Nokogiri::HTML(resp.body).css('h2:contains("Search Results")').first.parent
      {
        :titles => CDB::Title.parse_results(node)
      }
    end

  end
end
