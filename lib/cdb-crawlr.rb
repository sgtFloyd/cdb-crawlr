require 'nokogiri'
require 'open-uri'

$:.unshift(File.dirname(__FILE__))

require 'cdb/struct'
require 'cdb/issue'
require 'cdb/title'

module CDB
  VERSION = '0.0.1'

  BASE_URL = 'http://www.comicbookdb.com'
  REQUEST_HEADERS = {'Connection' => 'keep-alive'}
  SEARCH_PATH = 'search.php'

  class << self; attr

    def search(query, searchtype=nil)
      data = URI.encode_www_form(
        form_searchtype: searchtype,
        form_search: query
      )
      url = "#{BASE_URL}/#{SEARCH_PATH}?#{data}"
      response = open(url, REQUEST_HEADERS).read
      response.force_encoding('ISO-8859-1').encode!('UTF-8')
      doc = Nokogiri::HTML(response, nil, 'UTF-8')
      node = doc.css('h2:contains("Search Results")').first.parent
      {
        :titles => CDB::Title.parse_results(node),
        :issues => CDB::Issue.parse_results(node)
      }
    end

  end
end
