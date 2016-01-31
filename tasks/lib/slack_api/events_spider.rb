module SlackApi
  class EventsSpider < Spidey::AbstractSpider
    handle 'https://api.slack.com/events', :process_list

    def process_list(page, _default_data = {})
      page.search('.card tr').each do |event|
        tds = event.search('td')
        next unless tds.count == 2
        name = tds.first.text
        desc = tds.last.text
        href = event.search('a[href^="/events"]').first
        handle resolve_url(href[:href], page), :process_event, name: name, desc: desc
      end
    end

    def process_event(page, data = {})
        json_hash = {
          'name' => data[:name],
          'desc' => data[:desc] + '.',
          'long_desc' => page.search('.card p').map(&:text).join(" ").gsub("\n", " ")
        }

        example = JSON.parse(page.search('pre code')
            .text
            .gsub('…', '')
            .gsub('...', '')
            .gsub("\n", " ")
            .gsub(/\s+/, " ")
            .gsub(', }', '}')
            .gsub(', ]', ']')
        ) rescue nil

        json_hash['example'] = example if example

        record(file_name: 'events/' + data[:name] + '.json', json: JSON.pretty_generate(json_hash))
    end
  end
end
