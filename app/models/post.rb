class Post < ActiveRecord::Base

  after_commit :invalidate_first_page, on: :create

  #
  # this will make sure no one uses this verion cached
  # as it will miss this newly created record
  #
  def invalidate_first_page
    $redis.del('feed:first_page')
  end

  #
  # will check redis if it is there awesome return them
  # if not gets the last 10 posts created
  # and add them to redis for caching
  #  
  # DB performance
  #  Limit  (cost=0.15..1.07 rows=10 width=100)
  #    ->  Index Scan Backward using posts_pkey on posts  (cost=0.15..57.45 rows=620 width=100)
  # (2 rows)
  #
  # def self.first_page
  #   order('id desc').limit(10).to_json
  # end
  #
  # def self.first_page_with_cache
  #   page_name = "feed:first_page"
  #   cached = $redis.get(page_name)
  #   cache_and_return_page(page_name, order('id desc').limit(10).to_json)
  # end
  #
  #                  real       stime      utime      total
  # with c&failing   41.010000   1.580000  42.590000 ( 46.110835)  done 10000
  # without c        28.660000  0.850000   29.510000 ( 32.662422)  done 10000
  # with c           4.010000   0.170000   4.180000  (  4.182409)  done 10000
  #
  # this means that even if we have a 50% cache miss 
  # we beat the no caching model
  #
  # we can actually try to improve this method by retrieving json from db
  # the same applies to the next_page(id) method but in a more favorable way
  # the next_page(id) cache can help us in retrieving pages in the future 
  #
  # to handle the space complexity we should make expiry for the redis keys
  # also set a maximum size for it and set the maxmemory-policy to volatile-lru
  # but I think it is not the point of the test
  #
  def self.first_page_with_cache
    page_name = 'feed:first_page'
    cached = $redis.get(page_name)
    return cached if cached
    cache_and_return_page(page_name, order('id desc').limit(10).to_json)
  end

  #
  # will check redis if it is there awesome return them
  # if not gets the last 10 posts before the given id
  # and add them to redis for caching
  #
  def self.next_page(id)
    page_name = "feed:next_page:#{id}"
    cached = $redis.get(page_name)
    return cached if cached
    cache_and_return_page(page_name,
      where("id < #{id}").order('id desc').limit(10).to_json)
  end


  #
  # add the page to redis
  #
  def self.cache_and_return_page(page_name, json_results)
    $redis.set(page_name, json_results)
    return json_results
  end
end
