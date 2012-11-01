module CDB
  class Issue < Struct.new(:cdb_id, :title, :num, :name, :cover_date)
    FORM_SEARCHTYPE = 'IssueName'
    WEB_PATH = 'issue.php'

    class << self

      def search(query)
        results = CDB.search(query, FORM_SEARCHTYPE)
        results[:issues]
      end

      def parse_results(node)
        node.css("a[href^=\"#{WEB_PATH}\"]").map do |link|
          id = link.attr('href').split('=').last
          text = link.child.text.strip
          match = text.match(/^(.* \(\d{4}\)) (.*)$/)
          title, num = match[1..2]
          name = link.next_sibling.text.strip.gsub(/^-\s*"|"$/, '').strip
          new(:cdb_id => id, :title => title, :num => num, :name => name)
        end
      end

    end
  end
end
