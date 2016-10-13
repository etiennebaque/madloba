class User::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!
  before_action :requires_user
  after_action :verify_authorized
  after_action :update_ad_json, only: [:update]

  def show
    @item = Item.includes(:ads).where(id: params[:id]).first!
    authorize @item
    render 'item'
  end

  def new
    @adding = true
    @item = Item.new
    authorize @item
    render 'item'
  end

  def create
    @item = Item.new(item_params)
    authorize @item

    if @item.save
      flash[:new_name] = @item.name
      redirect_to edit_user_item_path(@item.id)
    else
      @isAdding = true
      render 'item'
    end
  end

  def edit
    @item = Item.includes(:ads).where(id: params[:id]).first!
    authorize @item
    render 'item'
  end

  def update
    @item = Item.find(params[:id])
    authorize @item

    if @item.update(item_params)
      flash[:name] = @item.name
      redirect_to edit_user_item_path
    else
      render 'item'
    end
  end

  def destroy
    @item = Item.find(params[:id])
    authorize @item
    deleted_item_name = @item.name

    if @item.destroy
      flash[:success] = t('admin.item.item_deleted', deleted_item_name: deleted_item_name)
      redirect_to user_managerecords_path
    else
      @item = Item.includes(:ads).where(id: params[:id]).first!
      render 'item'
    end

  end

  private

  def item_params
    params.require(:item).permit(:name, :category_id)
  end

  # Updates the relevant ads marker_info (jsonb) and update the category id in the 'markers' nested array.
  def update_ad_json
    if @item.errors.empty?
      ads = Ad.joins(:items).where('items.id = ?', params[:id])
      new_chosen_category = @item.category
      ads.each do |ad|
        if !ad.marker_info.empty?
          marker_info = ad.marker_info
          marker_info['markers'].each do |item|
            if item['item_id'] == params[:id].to_i
              item['category_id'] = new_chosen_category.id
              item['color'] = new_chosen_category.color
              item['icon'] = new_chosen_category.icon
            end
          end
          ad.marker_info = marker_info
          ad.save
        end
      end
    end
  end

end

