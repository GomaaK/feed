class PostsController < ApplicationController

  def index
    if params[:offset_id]
      render json: Posts.next_page(params[:offset_id])
    else
      render json: Posts.first_page_with_cache
    end
  end
end
