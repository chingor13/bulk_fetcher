# BulkFetcher

Fetch things in bulk and store them for later

## Basic Usage

```
fetcher = BulkFetcher.new(klass: MyActiveRecordClass)

# queue up some things to fix
fetcher.queue([1,2,3])
fetcher.queue(4)

# look up stuff - does single call for all items requested and queued
objects = fetcher.fetch_all(2,3,1)

# already fetched, so no additional find call
object = fetcher.fetch(4)
```

## Custom finder

```
fetcher = BulkFetcher.new(finder: lambda{|ids| MyActiveRecordClass.includes(:some_association).find(ids)})
```

## Custom index_by

Sometimes, if you want to find by some field other than `id`.

```
fetcher = BulkFetcher.new(finder: ->(ids) { MyActiveRecordClass.where(:some_key_id => ids).all },
                          index_by: :some_key_ids)
```