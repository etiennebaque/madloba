require 'rails_helper'
require 'spec_helper'

RSpec.describe User::ItemsController, :type => :controller do

  before :each do
    # Making sure we're not redirected to the setup screens.
    setting = Setting.find_or_create_by(key: 'setup_step')
    setting.value = 0
    setting.save

    # Creating admin user, and signing in.
    allow_message_expectations_on_nil
    @user = FactoryGirl.create(:user)
    @user.role = 1 # admin role
    @user.save
    sign_in @user
  end

  describe 'GET #show' do
    it 'assigns the requested item to @item' do
      item = FactoryGirl.create(:first_item)
      get :show, id: item
      expect(assigns(:item)).to eq(item)
    end

    it 'renders the right view' do
      get :show, id: FactoryGirl.create(:first_item)
      expect(response).to render_template('item')
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested item to @item' do
      item = FactoryGirl.create(:first_item)
      get :edit, id: item
      expect(assigns(:item)).to eq(item)
    end

    it 'renders the right view' do
      get :edit, id: FactoryGirl.create(:first_item)
      expect(response).to render_template('item')
    end
  end

  describe 'GET #new' do
    it 'instantiates a new @item' do
      get :new
      expect(assigns(:item)).to be_a_new(Item)
    end

    it 'renders the right view' do
      get :new
      expect(response).to render_template('item')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        @item = FactoryGirl.attributes_for(:first_item, category_id: FactoryGirl.create(:first_category))
      end

      it 'creates a new item' do
        expect{
          post :create, item: @item
        }.to change(Item,:count).by(1)
      end

      it 'redirects to the new item' do
        post :create, item: @item
        expect(response).to redirect_to :action => :edit, :id => assigns(:item).id
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new item' do
        expect {
          post :create, item: FactoryGirl.attributes_for(:invalid_item)
        }.to_not change(Item,:count)
      end

      it 're-renders the new method' do
        post :create, item: FactoryGirl.attributes_for(:invalid_item)
        expect(response).to render_template('item')
      end

    end
  end

  describe 'PUT #update' do
    before :each do
      @item = FactoryGirl.create(:first_item, name: 'old item name')
    end

    context 'with valid attributes' do
      it 'locates the requested @item' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:item)
        expect(assigns(:item)).to eq(@item)
      end

      it 'changes the @item attributes' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:item, name: 'new item name')
        @item.reload
        expect(@item.name).to eq('new item name')
      end

      it 'redirects to the updated @item' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:item)
        expect(response).to redirect_to :action => :edit, :id => assigns(:item).id
      end
    end

    context 'with invalid attributes' do
      it 'locates the requested @item' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:invalid_item)
        expect(assigns(:item)).to eq(@item)
      end

      it 'does not changes the @item attributes' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:item, name: nil)
        @item.reload
        expect(@item.name).not_to eq('new item name')
      end

      it 're-renders the edit method' do
        put :update, id: @item, item: FactoryGirl.attributes_for(:invalid_item)
        expect(response).to render_template('item')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @item = FactoryGirl.create(:first_item)
    end

    it 'deletes the item' do
      expect{
        delete :destroy, id: @item
      }.to change(Item,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @item
      expect(response).to redirect_to user_managerecords_path
    end
  end

end
