module CDB
  class Title < Struct.new(:cdb_id, :name, :issues, :publisher, :imprint, :begin_date, :end_date, :country, :language)
    FORM_SEARCHTYPE = 'Title'
    WEB_PATH = 'title.php'

    class << self

      def search(query)
        results = CDB.search(query, FORM_SEARCHTYPE)
        results[:titles]
      end

      def show(id)
        CDB.show(id, self)
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

      def parse_data(id, page)
        dates = page.css('strong:contains("Publication Date: ")').first.next_sibling.text.strip
        start_d, end_d = dates.split('-').map(&:strip)

        title = new(
          :cdb_id => id,
          :name => page.css('.page_headline').first.text.strip,
          :publisher => page.css('a[href^="publisher.php"]').first.text.strip,
          :imprint => page.css('a[href^="imprint.php"]').first.text.strip,
          :begin_date => start_d,
          :end_date => end_d,
          :country => page.css('strong:contains("Country: ")').first.next_sibling.text.strip,
          :language => page.css('strong:contains("Language: ")').first.next_sibling.text.strip
        )
        title.issues = page.css("td[width='726'] a.page_link[href^=\"#{CDB::Issue::WEB_PATH}\"]").map do |link|
          tr = link.parent.parent
          CDB::Issue.from_tr(tr, title)
        end
        title
      end
    end
  end
end
