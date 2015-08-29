require 'rubygems'
require 'bundler'
require 'fileutils'
require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'

def parse_args(api_page)
  args_wrapper = api_page.search("h2:contains('Arguments') + p + table")
  rows = args_wrapper.search("tr")
  args = []
  rows.each do |row|
    next if row.search("th").any?
    name = row.search("td:nth-child(1)").text()
    example = row.search("td:nth-child(2)").text()
    required = row.search("td:nth-child(3)").text() == 'Required' ? true : false
    desc = row.search("td:nth-child(4)").text().tap {|t| t.slice!("\n")}
    
    rows = args_wrapper.search("tr")

    arg = {
      name => {
        "required" => required,
        "example" => example,
        "required" => required,
        "desc" => desc
      } 
    }

    args << arg 
  end
  args
end

def parse_errors(api_page)
  errors_wrapper = api_page.search("h2:contains('Errors') + p + table")
  return nil unless errors_wrapper
  rows = errors_wrapper.search("tr")
  errors = {}
  rows.each do |row|
    next if row.search("th").any?

    name = row.search("td:nth-child(1)").text()
    desc = row.search("td:nth-child(2)").text().tap {|t| t.slice!("\n")}

    errors[name] = desc
  end
  errors
end

namespace :parse do
  namespace :api do
    desc "Parse api methods"
    task :methods do
      dir = 'methods'
      uri = 'https://api.slack.com/methods'
      FileUtils.rm_rf(dir)
      FileUtils.mkdir(dir)
      FileUtils.cd(dir) do
        doc = Nokogiri::HTML(open(uri))
        links = doc.css('.card a[href^="/methods"]') 
        links.each do |link|
          href = link.attributes["href"].value
          file_name = href.split("/").last + '.json'
          
          api_url  = "https://api.slack.com" + href
          puts api_url    
          api_page = Nokogiri::HTML(open(api_url))
          
          desc = api_page.search("section[data-tab='docs'] p")[0].text()
        
          args = parse_args(api_page) 
          errors = parse_errors(api_page) 
                       
          json_hash = {
            "desc" => desc, 
            "args" => args,
            "errors" => errors 
          }
          
          json = JSON.pretty_generate(json_hash)
          File.open(file_name, 'w+') {|f| f.write(json) }
        end        
      end
    end
  end
end
