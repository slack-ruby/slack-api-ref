module SlackApi
  class MethodsGenerator
    def downloader
      @downloader ||= SlackApi::Docs::Downloader.new
    end

    def generate!
      methods = JSON.load_file(downloader.methods_downloader.methods_path)
      groups = Set.new

      methods.each do |method_data|
        groups += method_data['family']

        method_filename = downloader.methods_downloader.method_target_path(method_data['name'])
        data = JSON.load_file(method_filename)

        process_method(
          data.merge(
            'name' => method_data['name'],
            'group' => method_data['family'].first.split('.').first
          )
        )
      end
    end

    private

    def process_method(data)
      args, fields = parse_args(data)

      errors = parse_errors(data)
      response = parse_response(data)

      result = {
        group: data['group'],
        name: data['name'],
        deprecated: false,
        desc: data['desc'],
        args: args,
        response: response,
        errors: errors
      }.merge(fields)

      filename = "methods/#{data['group']}/#{data['name']}.json"
      FileUtils.mkdir_p("methods/#{data['group']}")
      File.write(filename, JSON.pretty_generate(result))
    end

    def parse_args(data)
      args = {}
      fields = {}

      data['args']['properties'].each_pair do |name, arg|
        all = []
        arg['anyOf']&.each do |coll|
          all << coll['type'] unless coll['type'] == 'null'
        end
        arg['type'] = Array(all).length == 1 ? all.first : all if all.any?
        arg.delete('anyOf')

        type = massage_type(name, arg, data)
        required = data['args']['required']&.include?(name)

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

      [args.sort.to_h, fields]
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

    def parse_response(data)
      examples = []
      data['examples']&.each_pair do |_example_type, response|
        example = JSON.pretty_generate(response['example'], indent: '    ')
        example.gsub!(/\{\n\s*\}/, '{}')
        example.gsub!(/\[\n\s*\]/, '[]')
        examples.push example
      end
      { 'examples' => examples }
    end

    def parse_errors(data)
      errors = {}
      data['errors']&.each_pair do |name, desc|
        errors[name] = desc['desc']
      end
      errors
    end
  end
end
