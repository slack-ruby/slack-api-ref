module SlackApi
  class MethodsSpider < Spidey::AbstractSpider
    handle 'https://api.slack.com/methods', :process_list

    def process_list(page, _default_data = {})
      page.search('#api_main_content h2').each do |group|
        id = group.attr('id')
        next_p = group.next_sibling.next_sibling
        desc = next_p.text if next_p.name == 'p'
        file_name = 'groups/' + id + '.json'
        json_hash = { name: id }
        json_hash[:desc] = desc if desc
        record(file_name: 'groups/' + id + '.json', json: JSON.pretty_generate(json_hash))
      end
      page.search('table a[href^="/methods"]').each do |a|
        href = a.attr('href')
        method_name = href.split('/').last
        method_group = method_name.split('.').first
        file_name = 'methods/' + method_group + '/' + method_name + '.json'
        handle resolve_url(href, page), :process_method, filename: file_name, method_name: method_name, method_group: method_group
      end
    end

    def process_method(page, default_data = {})
      desc_p = page.search("section[data-tab='docs'] p").detect do |p|
        next if p.key?('class') && p['class'].include?('alert')
        p.text && p.text.strip.length > 0
      end

      desc = desc_p.text if desc_p

      ul = desc_p.next_sibling
      ul = ul.next_sibling if ul
      if ul && ul.name = 'ul'
        ul.search('li').each do |li|
          desc += "\n- #{li.text}"
        end
      end

      desc = desc.gsub("’", "'")

      args, fields = parse_args(page, default_data)
      errors = parse_errors(page)
      response = parse_response(page)

      json_hash = {
        'group' => default_data[:method_group],
        'name' => default_data[:method_name],
        'desc' => desc,
        'args' => args,
        'response' => response,
        'errors' => errors
      }.merge(fields)
      if deprecation = scrape_deprecation(page)
        json_hash.merge!(
          'deprecated' => true,
          'deprecation' => deprecation
        )
      end

      record(file_name: default_data[:filename], json: JSON.pretty_generate(json_hash))
    end

    private

    #
    # @param [Mechanize::Page] page - the page to scrape
    #
    # @return [Hash, nil] a Hash containing information about the deprecation or nil
    #
    def scrape_deprecation(page)
      div = page.search("#api_main_content .callout_warning div").first
      return unless div

      warning_text = div.children.first.text.sub('Learn more.', '').gsub(/\u00a0/, ' ').strip
      alternative_methods = div.search('li').map(&:text)

      return {
        deprecation_warning: warning_text,
        alternative_methods: alternative_methods
      }
    end

    def parse_args(api_page, default_data = {})
      args_wrapper = api_page.search("h2:contains('Arguments') + .method_arguments")
      rows = args_wrapper.search('.method_argument')
      args = {}
      fields = {}
      rows.each do |row|
        name = row.search('.arg_name').text
        example = row.search('.arg_example code').text
        required = row.search('.arg_required').any? ? true : false
        desc = row.search('.arg_desc p:first').text.tap { |t| t.slice!("\n") }.tap { |t| (t[-1] != '.') ? t << '.' : t }.gsub("’", "'")

        rows = args_wrapper.search('tr')

        case name
        when 'token' then
          # ignore token, always required
        when 'count', 'page' then
          fields['has_paging'] = true
          fields['default_count'] = 100
        else
          h = {}
          h['required'] = required
          h['example'] = example if example
          h['desc'] = desc if desc
          type = guess_type(name, default_data)
          h['type'] = type if type
          args[name] = h
        end
      end
      [args, fields]
    end

    def guess_type(name, default_data = {})
      case name
      when 'user' then 'user'
      when 'latest', 'oldest', 'ts' then 'timestamp'
      when 'file' then 'file'
      when 'user' then 'user'
      when 'channel' then
        case default_data[:method_group]
        when 'im' then 'im'
        when 'groups' then 'group'
        else 'channel'
        end
      end
    end

    def parse_response(api_page)
      responses = api_page.search("h2:contains('Response')")
      return nil unless responses
      examples = []
      responses.each do |response|
        response.xpath('//pre').each do |pre|
          text = pre.text.strip
          next unless text =~ /^\{.*\}$/m
          examples.push(text)
        end
      end
      { "examples" => examples }
    end

    def parse_errors(api_page)
      errors_wrapper = api_page.search("h2:contains('Errors') + p + table")
      return nil unless errors_wrapper
      rows = errors_wrapper.search('tr')
      errors = {}
      rows.each do |row|
        next if row.search('th').any?

        name = row.search('td:nth-child(1)').text
        desc = row.search('td:nth-child(2)').text.tap { |t| t.slice!("\n") }.tap { |t| (t[-1] != '.') ? t << '.' : t }

        errors[name] = desc
      end
      errors
    end
  end
end
