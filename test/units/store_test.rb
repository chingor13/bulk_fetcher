require 'test_helper'

class StoreTest < Minitest::Test
  class TestFinder
    def self.find(ids)
      did_find!
      Array(ids).map{|id| OpenStruct.new(:id => id, :name => "Object #{id}")}
    end

    def self.did_find!
      # hook for testing
    end
  end


  def test_only_finds_once_for_all_queued_items
    # should only find once
    TestFinder.expects(:did_find!).once

    fetcher = BulkFetcher::Store.new(klass: TestFinder)

    # queue up a few times
    fetcher.queue([1,2,3])
    fetcher.queue(4)

    # can find
    ret = fetcher.fetch_all([2,1,3])
    assert ret.is_a?(Array)
    assert_equal 3, ret.length

    # ensure returned in order
    assert_equal([2,1,3], ret.map(&:id))

    assert fetcher.fetch_all([1,4])
    assert fetcher.fetch(3)
  end

  def test_can_find_twice_for_missing_items
    TestFinder.expects(:did_find!).times(2)

    fetcher = BulkFetcher::Store.new(klass: TestFinder)

    fetcher.queue([1,2,3])

    assert ret = fetcher.fetch_all([1,2,3])

    # not queued, should make another fill-in request
    assert ret = fetcher.fetch(4)
  end

  def test_can_clear
    TestFinder.expects(:did_find!).times(2)

    fetcher = BulkFetcher::Store.new(klass: TestFinder)

    fetcher.queue([1,2,3])
    assert ret = fetcher.fetch_all([1,2,3])

    # clear the cache - should force another fetch
    fetcher.reset!
    assert ret = fetcher.fetch_all([1,2,3])
  end
end