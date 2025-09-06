# frozen_string_literal: true

module SlackApi
  # Scrapes Slack Web API method
  class MethodsSpider < BaseSpider
    handle 'https://docs.slack.dev/reference/methods/', :process_list

    def downloader
      @downloader ||= SlackApi::Docs::Downloader.new
    end

    def process_list(page, _default_data = {})
      methods = JSON.load_file(downloader.methods_path)

      groups = Set.new

      methods.each do |method|
        groups += method['family']
        method_name = method['name']
        method_group = method['family'].first.split('.').first
        downloaded_filename = downloader.method_target_path(method_name)
        file_name = "methods/#{method_group}/#{method_name}.json"
        method_url = resolve_url(downloader.method_url(method_name), page)
        handle method_url,
               :process_method,
               filename: file_name,
               downloaded_filename: downloaded_filename,
               method_name: method_name,
               method_group: method_group,
               method_url: method_url
      end

      groups.each do |group|
        file_name = "groups/#{group}.json"
        json_hash = { name: group }
        record(file_name: file_name, json: JSON.pretty_generate(json_hash))
      end
    end

    def process_method(method_page, default_data = {})
      method_data = JSON.load_file(default_data[:downloaded_filename])

      desc = method_data['desc'].gsub('’', "'")
      return if desc.downcase.start_with? 'Deprecated:'

      args, arg_groups, fields = parse_args(method_page, method_data)
      errors = parse_errors(method_page, method_data)
      response = parse_response(method_page, method_data)

      json_hash = {
        'group' => default_data[:method_group],
        'name' => default_data[:method_name],
        'deprecated' => false, # Deprecated methods are filtered out
        'desc' => desc,
        'args' => args,
        'arg_groups' => arg_groups,
        'response' => response,
        'errors' => errors
      }.compact.merge(fields)

      record(file_name: default_data[:filename], json: JSON.pretty_generate(json_hash))
    end

    private

    def parse_args(_api_page, method_data = {})
      args = {}
      fields = {}
      method_data['args']['properties'].each_pair do |name, arg|
        arg['anyOf']&.each do |coll|
          all = []
          all << coll['type']
          arg['type'] = all
        end
        arg.delete('anyOf')

        type = massage_type(name, arg, method_data)
        required = method_data['args']['required']&.include?(name)

        desc = arg['desc']
          &.tap { |t| t.slice!("\n") }
          &.tap { |t| t << '.' unless t.end_with?('.') }
          &.gsub('’', "'")
        example = arg['example'] || arg['default']

        case name
        when 'token'
          # ignore token, always required
        when 'count', 'page'
          fields['has_paging'] = true
          fields['default_count'] = 100
        else
          h = {}
          h['required'] = required
          h['example'] = example if example
          h['desc'] = desc if desc
          h['type'] = type if type
          h['format'] = 'json' if desc&.include?('JSON')
          args[name] = h
        end
      end

      arg_groups = parse_arg_groups(_api_page, method_data)

      [args.sort.to_h, arg_groups, fields]
    end

    def parse_arg_groups(_api_page, _method_data = {})
      groups = {}

      # # Look for groups of args that are interdependent
      # groups = args_wrapper.search('.apiMethodPage__argumentGroup')
      # groups = groups.map do |group|
      #   # "At least one of" or "One of"
      #   requirement = group.search('.apiMethodPage__argument em').text
      #   mutually_exclusive = requirement.downcase == 'one of'

      #   desc = group.search('.apiMethodPage__argumentGroupDesc p')
      #     .text
      #     .tap { |t| t&.slice!("\n") }
      #     .tap { |t| t << '.' unless t.end_with?('.') }
      #     .gsub('’', "'")

      #   rows = group.search('.apiMethodPage__argumentRow')
      #   names = rows.map do |row|
      #     row.search('.apiMethodPage__argument code').text
      #   end

      #   {
      #     'args' => names,
      #     'desc' => desc,
      #     'mutually_exclusive' => mutually_exclusive
      #   }
      # end

      groups unless groups.empty?
    end

    def massage_type(name, arg, data = {})
      return 'enum' if arg.key?('enum')

      case name
      when 'date' then 'date'
      when 'latest', 'oldest', 'ts' then 'timestamp'
      when 'file' then 'file'
      when 'bot', 'user' then 'user'
      when 'channel'
        case data[:method_group]
        when 'im' then 'im'
        when 'mpim' then 'mpim'
        when 'groups' then 'group'
        else 'channel'
        end
      else
        case detected = arg['type']
        when '', 'null' then nil
        else detected
        end
      end
    end

    def parse_response(_api_page, data = {})
      examples = []
      data['examples']&.each_pair do |_example_type, response|
        example = JSON.pretty_generate(response['example'], indent: '    ')
        example.gsub!(/\{\n\s*\}/, '{}')
        example.gsub!(/\[\n\s*\]/, '[]')
        examples.push example
      end
      { 'examples' => examples }
    end

    def parse_errors(_api_page, data = {})
      errors = {}
      data['errors']&.each_pair do |name, desc|
        errors[name] = desc['desc']
      end
      errors
    end
  end
end
