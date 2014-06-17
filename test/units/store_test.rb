require 'test_helper'

class StoreTest < Minitest::Test
  class TestFinder
    def self.find(ids)
      did_find!
      Array(ids).map{|id| OpenStruct.new(:id => id, :name => "Object #{id}")}
    end

    # hook for testing
    def self.did_find!; end
  end

  class CustomMethod
    def self.find(ids)
      Array(ids).map{|id| OpenStruct.new(:some_id => id, :name => "Object #{id}")}
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

  def test_can_set_custom_finder_method
    fetcher = BulkFetcher::Store.new(finder: lambda{|ids| ids.map{|id| OpenStruct.new(:id => id, :name => "Object #{id}")}})

    # queue up a few times
    fetcher.queue([1,2,3])
    fetcher.queue(4)
    
    ret = fetcher.fetch_all([2,1,3])
    assert ret.is_a?(Array)
    assert_equal 3, ret.length
  end

  def test_can_set_custom_index_by_method
    fetcher = BulkFetcher::Store.new(klass: CustomMethod, index_by: :some_id)
    fetcher.queue([1,2,3])
    ret = fetcher.fetch(2)
    assert_equal(2, ret.some_id)
  end

  def test_must_supply_finder
    assert_raises ArgumentError do
      fetcher = BulkFetcher::Store.new
    end
  end

end