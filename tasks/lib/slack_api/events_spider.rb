module SlackApi
  class EventsSpider < Spidey::AbstractSpider
    handle 'https://api.slack.com/events', :process_list

    def process_list(page, _default_data = {})
      page.search('.card tr').each do |event|
        tds = event.search('td')
        next unless tds.count >= 3
        name, desc, required_scope = tds.map(&:text).map(&:strip)
        next unless required_scope == "RTM"
        href = event.search('a[href^="/events"]').first
        handle resolve_url(href[:href], page), :process_event, name: name, desc: desc, required_scope: required_scope
      end
    end

    def process_event(page, data = {})
      long_desc = page.search('.card p, .card h4').map(&:text).join(" ").gsub("\n", " ")
      long_desc = long_desc.gsub ' Compatibility: RTM Events API', '.'
      long_desc = long_desc.gsub ' Compatibility: RTM', '.'
      long_desc = long_desc.gsub /Events API compatibility.*$/, ''
      long_desc = long_desc.gsub /.*API Scope:\s*[\w:]*/, ''
      long_desc = long_desc.strip

      json_hash = {
        'name' => data[:name],
        'desc' => data[:desc] + '.',
        'long_desc' => long_desc,
        'required_scope' => data[:required_scope]
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
