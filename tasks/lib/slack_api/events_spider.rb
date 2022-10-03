# frozen_string_literal: true

module SlackApi
  # Scrapes Slack events
  class EventsSpider < BaseSpider
    handle 'https://api.slack.com/events', :process_list

    def process_list(page, _default_data = {})
      events_page = ensure!(page, '.apiEventsPage')
      list = events_page.search('.apiEventPage__eventList')
      ref = list.search('[data-automount-component=ApiDocsFilterableReferenceList]')
      data = JSON.parse(ref.attribute('data-automount-props'))
      raise(ElementNotFound, 'Could not parse events reference') unless data['items'].any?

      data['items'].each do |event|
        next unless event['isPublic']
        next if event['isDeprecated']
        next unless event['groups'].include?('RTM')

        handle resolve_url(event['link'], page),
               :process_event,
               name: event['name'],
               desc: event['description'],
               required_scope: 'RTM'
      end
    end

    def process_event(page, data = {})
      event_page = ensure!(page, '.apiEventPage', data[:name])
      descriptions = event_page.search('.apiDocsPage__markdownOutput p')
      long_desc = descriptions.map(&:text).join(' ').gsub("\n", ' ').strip
      # required_scopes = event_page.search('.apiReference__scope code').map(&:text).map(&:strip).join(', ')

      json_hash = {
        'name' => data[:name],
        'desc' => "#{data[:desc]}.",
        'long_desc' => long_desc,
        'required_scope' => data[:required_scope]
      }

      example = begin
        JSON.parse(
          event_page.search('.apiDocsPage__markdownOutput pre:first code')
            .text
            .gsub('…', '')
            .gsub('...', '')
            .gsub("\n", ' ')
            .gsub(/\s+/, ' ')
            .gsub(', }', '}')
            .gsub(', ]', ']')
        )
      rescue StandardError
        nil
      end

      json_hash['example'] = example if example

      record(file_name: "events/#{data[:name]}.json", json: JSON.pretty_generate(json_hash))
    end
  end
end
