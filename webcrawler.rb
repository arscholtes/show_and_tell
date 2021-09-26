# Language: Ruby, Level: Level 3
# A web crawler in Ruby
#
# This script provides a generic Spider class for crawling urls and
# recording data scraped from websites. The Spider is to be used in
# collaboration with a "processor" class that defines which pages to
# visit and how data from those pages should be consumed.
#
# Usage:
#   spider = Techpoint.new
#   spider.results.take(10)
#   => [{...}, {...}, ...]
#
# Requirements:
#   Ruby 2.0+
#
# Based on Rossta's blog post about webcrawlers
#

require 'mechanize'
require 'pry'
require 'fast_gettext'

class Spider
  REQUEST_INTERVAL = 1
  MAX_URLS = 10

  attr_reader :handlers

  def initialize(processor, options = {})
    @processor = processor

    @urls      = []
    @results   = []
    @handlers  = {}

    @interval = options.fetch(:interval, REQUEST_INTERVAL)
    @max_urls = options.fetch(:max_urls, MAX_URLS)

  enqueue(@processor.root, @processor.handler)
  end

  # Attaching URLs with their Handlers and putting them in a running list.
  # Setting up the queue of URLs that we will itterate through and grab data.
  #

  def enqueue(url, method, data = {})
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: data }
  end

  #

  def record(data = {})
    @results << data
  end

  #

  def results
    return enum_for(:results) unless block_given?

    i = @results.length
    enqueued_urls.each do |url, handler|
      begin
        log "Handling", url.inspect
        @processor.send(handler[:method], agent.get(url), handler[:data])
        if block_given? && @results.length > i
          yield @results.last
          i += 1
        end
      rescue => ex
        log "Error", "#{url.inspect}, #{ex}"
      end
      sleep @interval if @interval > 0
    end
  end


  private

  #

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

  #

  def log(label, info)
    warn "%-10s: %s" % [label, info]
  end

  #

  def agent
    @agent ||= Mechanize.new
  end
end

# Wrap spider and extract data

class Techpoint
  attr_reader :root, :handler

  #

  #def initialize(root: "https://techpoint.org/", handler: :process_index, **options)
  #  @root = root
  #  @handler = handler
  #  @options = options
  #end

  def initialize(root: "https://programmableweb.com/apis/directory", handler: :process_index, **options)
    @root = root
    @handler = handler
    @options = options
  end

#

def process_index(page, data = {})
  page.links_with(href: /\?page=\d+/).each do |link|
    spider.enqueue(link.href, :process_index)
  end

  #

  page.links_with(href: %r{/twitter\b}).each do |link|
    spider.enqueue(link.href, :process_twitter, name: link.text)
  end
end

#

#def process_api(page, data = {})
#  categories = page.search("article.node-api .tags").first.text.strip.split(/\s+/)
#  fields = page.search("#tabs-content .field").each_with_object({}) do |tag, results|
#    key = tag.search("label").text.strip.downcase.gsub(/[^\w]+/, ' ').gsub(/\s+/, "_").to_sym
#    val = tag.search("span").text
#    results[key] = val
#  end

  def process_twitter(page, data = {})
    categories = page.search("article.node-api .tags").first.text.strip.split(/\s+/)
    fields = page.search("#tabs-content .field").each_with_object({}) do |tag, results|
      key = tag.search("label").text.strip.downcase.gsub(/[^\w]+/, ' ').gsub(/\s+/, "_").to_sym
      val = tag.search("span").text
      results[key] = val
    end

    spider.record data.merge(fields).merge(categories: categories)
  end

#

def results(&block)
  spider.results(&block)
end

  private

  #

  def spider
    @spider ||= Spider.new(self, @options)
  end
end

#

if __FILE__ == $0
  spider = Techpoint.new

  #

  spider.results.lazy.take(5).each_with_index do |result, i|
    warn "%-2: %s" % [i, result.inspect]
  end
end
