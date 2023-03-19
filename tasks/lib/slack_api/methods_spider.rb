# frozen_string_literal: true

module SlackApi
  # Scrapes Slack Web API method
  class MethodsSpider < BaseSpider
    handle 'https://api.slack.com/methods', :process_list

    def process_list(page, _default_data = {})
      methods_page = ensure!(page, '.apiMethodPage')
      list = methods_page.search('.apiMethodPage__methodList')
      ref = list.search('[data-automount-component=ApiDocsFilterableReferenceList]')
      data = JSON.parse(ref.attribute('data-automount-props'))
      raise(ElementNotFound, 'Could not parse methods reference') unless data['items'].any?

      groups = Set.new
      data['items'].each do |method|
        next unless method['isPublic']
        next if method['isDeprecated']

        groups += method['groups']
        method_name = method['name']
        method_group = method['groups'].first.split('.').first
        file_name = "methods/#{method_group}/#{method_name}.json"
        method_url = resolve_url(method['link'], page)
        handle method_url,
               :process_method,
               filename: file_name,
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

    def process_method(page, default_data = {})
      method_page = ensure!(page, '.apiMethodPage', default_data[:method_name])
      desc = method_page.search('.apiReference__mainDescription').text.gsub('’', "'")
      return if desc.downcase.start_with? 'deprecated:'

      args, arg_groups, fields = parse_args(method_page, default_data)
      errors = parse_errors(method_page, default_data)
      response = parse_response(method_page, default_data)

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

    def parse_args(api_page, default_data = {})
      args_wrapper = ensure!(api_page, '.apiReference__arguments', default_data[:method_name])
      rows = args_wrapper.search('.apiMethodPage__argumentRow')
      args = {}
      fields = {}
      rows.each do |row|
        name = row.search('.apiMethodPage__argument code').text
        type = massage_type(name,
                            row.search('.apiMethodPage__argumentType').text,
                            default_data)
        required = row.search('.apiMethodPage__argumentOptionality--required').any?

        desc = row.search('.apiMethodPage__argumentDesc p')
          .text
          .tap { |t| t.slice!("\n") }
          .tap { |t| t << '.' unless t.end_with?('.') }
          .gsub('’', "'")
        example = row.search('.apiReference__example__code').first&.text

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

      arg_groups = parse_arg_groups(args_wrapper)

      [args, arg_groups, fields]
    end

    def parse_arg_groups(args_wrapper)
      # Look for groups of args that are interdependent
      groups = args_wrapper.search('.apiMethodPage__argumentGroup')
      groups = groups.map do |group|
        # "At least one of" or "One of"
        requirement = group.search('.apiMethodPage__argument em').text
        mutually_exclusive = requirement.downcase == 'one of'

        desc = group.search('.apiMethodPage__argumentGroupDesc p')
          .text
          .tap { |t| t.slice!("\n") }
          .tap { |t| t << '.' unless t.end_with?('.') }
          .gsub('’', "'")

        rows = group.search('.apiMethodPage__argumentRow')
        names = rows.map do |row|
          row.search('.apiMethodPage__argument code').text
        end

        {
          'args' => names,
          'desc' => desc,
          'mutually_exclusive' => mutually_exclusive
        }
      end

      groups unless groups.empty?
    end

    def massage_type(name, detected, default_data = {})
      case name
      when 'date' then 'date'
      when 'latest', 'oldest', 'ts' then 'timestamp'
      when 'file' then 'file'
      when 'bot', 'user' then 'user'
      when 'channel'
        case default_data[:method_group]
        when 'im' then 'im'
        when 'mpim' then 'mpim'
        when 'groups' then 'group'
        else 'channel'
        end
      else
        case detected
        when '', 'null' then nil
        else detected
        end
      end
    end

    def parse_response(api_page, default_data = {})
      response_wrapper = ensure!(api_page, '.apiReference__response', default_data[:method_name])
      responses = response_wrapper.search('.apiReference__example')
      examples = []
      responses.each do |response|
        response.search('pre').each do |pre|
          text = pre.text.strip
          next unless text =~ /^\{.*}$/m

          examples.push(text)
        end
      end
      { 'examples' => examples }
    end

    def parse_errors(api_page, default_data = {})
      errors_wrapper = ensure!(api_page, '.apiReference__errors', default_data[:method_name])
      rows = errors_wrapper.search('.apiDocsTable tr')
      errors = {}
      rows.each do |row|
        next if row.search('th').any?

        name = row.search('[data-label=Error]').text
        desc = row.search('[data-label=Description]').text
          .tap { |t| t.slice!("\n") }
          .tap { |t| t << '.' unless t.end_with?('.') }

        errors[name] = desc
      end
      errors
    end
  end
end
