module SlackApi
  class BaseSpider < Spidey::AbstractSpider
    class ElementNotFound < StandardError; end

    def ensure!(root, selector, label = nil)
      label ||= self.class.name.split('::').last.gsub('Spider', '').downcase
      element = root.search(selector)
      return element if element.any?

      raise ElementNotFound, "Could not find #{selector} for #{label}"
    end
  end
end
