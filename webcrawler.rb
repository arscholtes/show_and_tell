# Language: Ruby, Level: Level 3
# A web crawler in Ruby
#
# This script provides a generic Spider class for crawling urls and
# recording data scraped from websites. The Spider is to be used in
# collaboration with a "processor" class that defines which pages to
# visit and how data from those pages should be consumed.
#
# Usage:
#   spider = ProgrammableWeb.new
#   spider.results.take(10)
#   => [{...}, {...}, ...]
#
# Requirements:
#   Ruby 2.0+
#
# Based on Rossta's blog post about webcrawlers
#
require "mechanize"
require "pry"

class Spider

  def initialize(processor, attrs = {})
    @processor = prcessor
    @urls      = []
    @results   = []
    @handlers  = []

    @interval = attrs.fetch(:interval, REQUEST_INTERVAL)
    @max_urls = attrs.fetch(:max_urls, MAX_URLS)

  enqueue(processor.root, processor.handler)
  end


  # Attaching URLs with their Handlers and putting them in a running list.
  def enqueue(url, method)
    url = agent.resolve(url).to_s
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: {} }
  end

  # Throwing the data that is scraped into a container(@results).

  def record(data = {})
    @results << data
  end

  def results
    return enum_for(:results) unless block_given?

    index = @results.length
    enqueued_urls.each do |url, handler|

      # Process the urls
      @processor.send(handler[:method], agent.get(url), handler[:data])

      if block_given? && @results.length > index
        yield @results.last
        index += 1
      end

      # Add delay
      sleep @interval if @interval > 0
    end
  end

  private
# Itterate through URL queue
  def enqueued_urls
    Enumerator.new do |y|
      index = 0
      while index < @urls.count && index <= @max_urls
        url = @urls[index]
        index += 1
        next unless url
        y.yield url, @handlers[url]
      end
    end
  end

  def log(label, info) # Not part of the article
    warn "%-10s: %s" % [label, info]
  end

  def agent
    @agent ||= Mechanize.new
  end
end


# Wrap spider and extract data


class Techpoint
  attr_reader :root, :handler

  def initialize(root: "https://techpoint.org/", handler: :process_index, **options)
    @root = root
    @handler = handler
    @options = options
  end

# Grab api names from index list

def process_index(page, data = {})
  page.links_with(href: %r{\?page=\d+}).each do |link|
    spider.enqueue(link.href, :process_index)
  end

  page.links_with(href: %r{/api/\w+$}).each do |link|
    spider.enqueue(link.href, :process_api, name: link.text)
  end
end

# Grab

# def process_api(page, data = {})
#   fields = page.search("#{tabs-content .field}").each_with_object({}) do |tag, o|
#    key = tag.search("label").text.strip.downcase.gsub(%r{[^\w]+}, ' ').gsub(%r{\s+}.to_sym)
#    val = tag.search("span").text
#    o[key] = val
#  end
#
#  categories = page.search("article.node-api .tags").first.text.strip.split(/\s+/)
#
#  spider.record data.merge(fields).merge(categories: categories)
#end

  def process_api(page, data = {})
  categories = page.search("article.node-api .tags").first.text.strip.split(/\s+/)
  fields = page.search("#tabs-content .field").each_with_object({}) do |tag, results|
    key = tag.search("label").text.strip.downcase.gsub(/[^\w]+/, ' ').gsub(/\s+/, "_").to_sym
    val = tag.search("span").text
    results[key] = val
  end

  spider.record data.merge(fields).merge(categories: categories)
end

def results(&block)
  spider.results(&block)
end

  private

  def spider
    @spider ||= Spider.new(self, @options)
  end
end

if __FILE__ == $0
  spider = Techpoint.new

  spider.results.lazy.take(5).each_with_index do |result, i|
    warn "%-2: %s" % [i, result.inspect]
  end
end
