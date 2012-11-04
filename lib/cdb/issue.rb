module CDB
  class Issue < Struct.new(:cdb_id, :series, :num, :name, :story_arc, :cover_date)
    FORM_SEARCHTYPE = 'IssueName'
    WEB_PATH = 'issue.php'

    class << self

      def search(query)
        results = CDB.search(query, FORM_SEARCHTYPE)
        results[:issues]
      end

      def parse_results(node)
        node.css("a[href^=\"#{WEB_PATH}\"]").map do |link|
          id = link.attr('href').split('=').last.to_i
          text = link.child.text.strip
          match = text.match(/^(.* \(\d{4}\)) (.*)$/)
          series = match[1]
          num = match[2].gsub(/^#/, '')
          name = link.next_sibling.text.strip.gsub(/^-\s*"|"$/, '').strip
          new(:cdb_id => id, :series => series, :num => num, :name => name)
        end.sort_by(&:cdb_id)
      end

      def from_tr(node, series)
        tds = node.css('td')
        link = tds[0].css("a[href^=\"#{WEB_PATH}\"]").first
        new(:cdb_id => link['href'].split('=').last.strip.to_i,
            :series => series,
            :num => link.text.strip,
            :name => tds[2].text.strip,
            :story_arc => tds[4].text.strip,
            :cover_date => tds[6].text.strip)
      end

    end
  end
end
