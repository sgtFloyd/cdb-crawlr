module CDB
  class Title < Struct.new(:cdb_id, :name, :publisher, :begin_date, :end_date)
    FORM_SEARCHTYPE = 'Title'
    WEB_PATH = 'title.php'

    class << self

      def search(query)
        results = CDB.search(query, FORM_SEARCHTYPE)
        results[:titles]
      end

      def parse_results(node)
        node.css("a[href^=\"#{WEB_PATH}\"]").map do |link|
          id = link.attr('href').split('=').last.to_i
          text = link.child.text.strip
          name = text.slice(0..-8)
          year = text.slice(-5..-2)
          pub = link.next_sibling.text.gsub(/^\s*\(|\)\s*$/, '')
          new(:cdb_id => id, :name => name, :publisher => pub, :begin_date => year)
        end.sort_by(&:cdb_id)
      end

    end
  end
end
