module SlackApi
  class EventsGenerator
    def downloader
      @downloader ||= SlackApi::Docs::Downloader.new
    end

    def generate!
      events = JSON.load_file(downloader.events_downloader.events_path)

      events.each do |data|
        event_data = {
          'name' => data['name'],
          'desc' => "#{data['description']}.",
          'scopes' => data['scopes'] || [],
          'APIs' => data['APIs']
        }
        process_event(event_data)
      end

      existing_events = Dir.glob('events/**/*.json').grep_v(%r{/_patches\b})
      updated_events = events.map { |event| "events/#{event['name']}.json" }
      (existing_events - updated_events).each do |removed_event|
        puts "(delete) #{removed_event}"
        File.delete(removed_event)
      end
    end

    private

    def process_event(data)
      filename = "events/#{data['name']}.json"
      puts filename
      existing_event_data = File.exist?(filename) ? JSON.load_file(filename) : {}
      all_data = existing_event_data.merge(data)
      File.write(filename, JSON.pretty_generate(all_data))
    end
  end
end
