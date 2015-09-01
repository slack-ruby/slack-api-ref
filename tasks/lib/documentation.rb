class SlackApiDocumentationSpider < Spidey::AbstractSpider
  handle 'https://api.slack.com/methods', :process_list

  def process_list(page, _default_data = {})
    page.search('.card a[href^="/methods"]').each do |a|
      href = a.attr('href')
      file_name = href.split('/').last + '.json'
      handle resolve_url(href, page), :process_method, filename: file_name
    end
  end

  def process_method(page, default_data = {})
    desc = page.search("section[data-tab='docs'] p")[0].text

    args = parse_args(page)
    errors = parse_errors(page)

    json_hash = {
      'desc' => desc,
      'args' => args,
      'errors' => errors
    }
    record(file_name: default_data[:filename], json: JSON.pretty_generate(json_hash))
  end

  private

  def parse_args(api_page)
    args_wrapper = api_page.search("h2:contains('Arguments') + p + table")
    rows = args_wrapper.search('tr')
    args = []
    rows.each do |row|
      next if row.search('th').any?
      name = row.search('td:nth-child(1)').text
      example = row.search('td:nth-child(2)').text
      required = row.search('td:nth-child(3)').text == 'Required' ? true : false
      desc = row.search('td:nth-child(4)').text.tap { |t| t.slice!("\n") }.tap { |t| (t[-1] != '.') ? t << '.' : t }

      rows = args_wrapper.search('tr')

      arg = {
        name => {
          'required' => required,
          'example' => example,
          'desc' => desc
        }
      }

      args << arg
    end
    args
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
