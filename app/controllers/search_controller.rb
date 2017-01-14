class SearchController < ApplicationController

  def render_search_results_partial
    result = ''

    # An item is being searched.
    @selected_posts = Post.joins(:items).where('items.name LIKE ?', "%#{params[:item].downcase}%", giving: giving?)
    @selected_posts.each do |post|
      result += Result.create(post)
    end

    render json: {results: result, categories: @selected_posts.map{|p| p.category_id.to_s}.uniq}
  end

  private

  def giving?(params)
    params[:q] == 'giving'
  end

end