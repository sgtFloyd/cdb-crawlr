require 'nokogiri'
require 'open-uri'

$:.unshift(File.dirname(__FILE__))

require 'cdb/struct'
require 'cdb/issue'
require 'cdb/title'

module CDB
  VERSION = '0.0.2'

  BASE_URL = 'http://www.comicbookdb.com'
  REQUEST_HEADERS = {'Connection' => 'keep-alive'}
  SEARCH_PATH = 'search.php'

  class << self; attr

    def search(query, type='FullSite')
      data = URI.encode_www_form(
        form_searchtype: type,
        form_search: query
      )
      url = "#{BASE_URL}/#{SEARCH_PATH}?#{data}"
      content = open(url, REQUEST_HEADERS).read
      content.force_encoding('ISO-8859-1').encode!('UTF-8')
      doc = Nokogiri::HTML(content)
      node = doc.css('h2:contains("Search Results")').first.parent
      {
        :titles => CDB::Title.parse_results(node),
        :issues => CDB::Issue.parse_results(node)
      }
    end

  end
end
