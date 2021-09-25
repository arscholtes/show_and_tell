require "mechanize"

class Spider

  def initialize(processor, attrs = {})
    @processor = prcessor
    # Zero everything out.
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

    i = @results.length
    enqqueued_urls.each do |url, handler|

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

  def enqueued_urls
    Enumerator.new do |y|
      index = 0
      while index < @urls.count && index <= @max_urls
        url = @urls[index]
        index +=
        next unless url
        y.yield url, @handlers[url]
      end
    end
  end



  private

  def agent
    @agent ||= Mechanize.new
  end
end


# No clue where this is going to go quite yet or how to
# require "pstore"
# store  = PStore.new("api_directore.pstore")

# create `spider`, then ...

# spider.results.lazy.take(50).each_with_index do |result, i|
#   store.transaction do
#     store[result[:name]] = result
#     store.commit
#   end
# end
