module BulkFetcher
  class Store
    attr_reader :klass, :id_queue, :cache, :finder

    def initialize(options = {})
      @klass = options.fetch(:klass)
      @finder = options.fetch(:finder) do
        klass.method(:find)
      end
      reset!
    end
   
    def queue(ids)
      id_queue.concat(Array(ids))
    end
   
    # returns objects in the order they 
    def fetch_all(id_or_ids)
      ids = Array(id_or_ids)
   
      # look in the cache for hits
      items, missing_ids = lookup_items(ids)
   
      # bulk fetch the missing ids
      fetch_items(missing_ids + read_queue)

      new_items, missing_ids = lookup_items(missing_ids)
      items_by_id = (items + new_items).inject({}){ |collection, item| collection[item.id] = item; collection}

      ids.map{|id| items_by_id[id] }
    end
   
    # return a single object
    def fetch(id)
      fetch_all(id).first
    end
   
    def reset!
      @cache = {}
      @id_queue = []
    end
   
    protected

    def read_queue
      id_queue.dup.tap do |q|
        id_queue.clear
      end
    end
   
    def lookup_items(ids)
      missing = []
      items = []
   
      # find cache hits first
      ids.each do |id|
        if item = cache[id]
          items.push(item)
        else
          missing.push(id)
        end
      end
      [items, missing]
    end
   
    def fetch_items(ids)
      return [] if ids.empty?
   
      items = finder.call(ids)
      store_items(items)
    end
   
    def store_items(objects)
      Array(objects).each do |object|
        cache[object.id] = object
      end
    end

  end
end