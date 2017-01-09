class SearchController < ApplicationController

  def render_search_results_partial
    result = ''
    if params[:item] && params[:item] != ''
      # An item is being searched.
      #selected_item_ids = Item.joins(:posts).where('name LIKE ?', "%#{params[:item].downcase}%").pluck(:id).uniq
      @selected_posts = Post.joins(:items).where('items.name LIKE ?', "%#{params[:item].downcase}%")
      @selected_posts.each do |post|
        result += Result.create(post)
      end
    end

    render json: {results: result, categories: @selected_posts.map{|p| p.category_id.to_s}.uniq}
  end
end