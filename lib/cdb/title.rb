module CDB
  class Title < Struct.new(:cdb_id, :name, :publisher, :imprint, :begin_date, :end_date, :country, :language)
    FORM_SEARCHTYPE = 'Title'
    WEB_PATH = 'title.php'

    class << self

      def search(query)
        results = CDB.search(FORM_SEARCHTYPE, query)
        results[:titles]
      end

      def parse_results(node)
        node.css("a[href^=\"#{WEB_PATH}\"]").map do |link|
          id = link.attr('href').split('=').last
          text = link.child.text.strip
          name = text.slice(0..-8)
          pub = link.next_sibling.text.strip.gsub(/^\(|\)$/, '')
          new(:cdb_id => id, :name => name, :publisher => pub, :begin_date => year)
        end
      end

    end
  end
end
