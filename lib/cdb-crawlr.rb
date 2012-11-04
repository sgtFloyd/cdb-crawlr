require 'json'
require 'nokogiri'
require 'open-uri'

$:.unshift(File.dirname(__FILE__))

require 'cdb/cli'
require 'cdb/struct'
require 'cdb/issue'
require 'cdb/series'

module CDB
  VERSION = '0.2.0'

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
      doc = read_page(url)
      node = doc.css('h2:contains("Search Results")').first.parent
      {
        :series => CDB::Series.parse_results(node),
        :issues => CDB::Issue.parse_results(node)
      }
    end

    def show(id, type)
      data = URI.encode_www_form('ID' => id)
      url = "#{BASE_URL}/#{type::WEB_PATH}?#{data}"
      page = read_page(url)
      type.parse_data(id, page)
    end

  private

    def read_page(url)
      content = open(url, REQUEST_HEADERS).read
      content.force_encoding('ISO-8859-1').encode!('UTF-8')
      Nokogiri::HTML(content)
    end

  end
end
