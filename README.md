# BulkFetcher

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