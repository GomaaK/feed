require 'rails_helper'

describe Post, type: :model do

  describe 'cache' do
    it 'starts clean' do
      
    end

    it 'saves after the first request' do
      
    end

    it 'invalidates after someone creates' do
      
    end
  end

  describe 'first_page' do

    before  do 
      $redis.del('feed:first_page')
      Post.destroy_all
    end

    let(:created_post) { FactoryGirl.create_list(:post, 10) }

    let(:last_post_of_previous_page_id) { created_post.last['id'] }

    let(:posts_json) { Post.first_page_with_cache }

    let(:posts) { JSON.parse(posts_json) }

    it 'starts by querying the db' do
      ids = last_post_of_previous_page_id
      expect(posts.first['id']).to  eq(ids)
    end

    it 'retrieves from redis if already' do
      
    end

    it 'querying the db after someone creates' do
      
    end

  end

  describe 'next_page' do

    let(:created_post) { FactoryGirl.create_list(:post, 20) }

    let(:last_post_of_previous_page_id) { created_post[9]['id'] }

    let(:posts_json) { Post.next_page(last_post_of_previous_page_id) }

    let(:posts) { JSON.parse(posts_json) }

    it 'starts by querying the db' do
      ids = last_post_of_previous_page_id
      expect(posts.first['id']).to  eq(last_post_of_previous_page_id - 1)
    end

    it 'retrieves from redis if already' do
      
    end

  end

end
