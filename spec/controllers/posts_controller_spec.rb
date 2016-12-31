require 'rails_helper'

RSpec.describe User::PostsController, :type => :controller do

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

    @location = FactoryGirl.create(:location, user_id: @user.id)
    @location.save

    sign_in @user
  end

  describe 'GET #show' do
    it 'assigns the requested post to @post' do
      post = FactoryGirl.create(:post_with_items, user: @user)
      get :show, id: post.id
      expect(assigns(:post)).to eq(post)
    end

    it 'renders the right view' do
      post = FactoryGirl.create(:post_with_items, user: @user)
      get :show, id: post.id
      expect(response).to render_template('show')
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested item to @post' do
      post = FactoryGirl.create(:post_with_items, user: @user)
      get :edit, id: post.id
      expect(assigns(:post)).to eq(post)
    end

    it 'renders the right view' do
      post = FactoryGirl.create(:post_with_items, user: @user)
      get :edit, id: post.id
      expect(response).to render_template('edit')
    end
  end

  describe 'GET #new' do
    it 'instantiates a new @item' do
      get :new
      expect(assigns(:post)).to be_a_new(Post)
    end

    it 'renders the right view' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        @item_1 = FactoryGirl.create(:item)
        @item_2 = FactoryGirl.create(:item)
        @category = FactoryGirl.create(:first_category)
        @valid_post_attributes_with_signed_in_user = FactoryGirl.attributes_for(:post).merge(
            user_id: @user.id,
            item_ids: [@item_1.id, @item_2.id].join(','),
            category_id: @category.id,
            location_attributes: FactoryGirl.attributes_for(:location, user_id: @user.id)
        )

        @valid_post_attributes_with_anonymous_user = FactoryGirl.attributes_for(:post_with_anon_user_only).merge(
            user_id: nil,
            item_ids: [@item_1.id, @item_2.id].join(','),
            category_id: @category.id,
            location_attributes: FactoryGirl.attributes_for(:location, user_id: @user.id)
        )
      end

      it 'creates a new post, with signed-in user' do
        expect{
          post :create, post: @valid_post_attributes_with_signed_in_user
        }.to change(Post,:count).by(1)
      end

      it 'redirects to the new post, after creation of post with signed-in user' do
        post :create, post: @valid_post_attributes_with_signed_in_user
        expect(response).to redirect_to :action => :show, :id => assigns(:post).id
      end

      it 'creates a new post, with an anonymous user (not signed-in)' do
        sign_out @user
        expect{
          post :create, post: @valid_post_attributes_with_anonymous_user
        }.to change(Post,:count).by(1)
      end

      it 'redirects to the new post, after creation of post with anonymous user' do
        sign_out @user
        post :create, post: @valid_post_attributes_with_anonymous_user
        expect(response).to redirect_to :action => :show, :id => assigns(:post).id
      end
    end

    context 'with invalid attributes' do
      before (:all) do
        @item = FactoryGirl.create(:item)
      end

      it 'does not save the new post' do
        expect {
          post :create, post: FactoryGirl.attributes_for(:invalid_post, user: @user, item_ids: @item.id, location: FactoryGirl.create(:location))
        }.to_not change(Post,:count)
      end


      it 're-renders the new method' do
        post :create, post: FactoryGirl.attributes_for(:invalid_post, item_ids: @item.id)
        expect(response).to render_template('new')
      end

    end
  end

  describe 'PUT #update' do
    before :each do
      @post = FactoryGirl.create(:post_with_items, user: @user, title: 'old post title')
    end

    context 'with valid attributes' do

      it 'locates the requested @post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post_with_other_items)
        expect(assigns(:post)).to eq(@post)
      end

      it 'changes the @post attributes' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post_with_other_items, title: 'new post title')
        @post.reload
        expect(@post.title).to eq('new post title')
      end

      it 'redirects to the updated @post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post_with_other_items)
        expect(response).to redirect_to :action => :edit, :id => assigns(:post).id
      end

    end

    context 'with invalid attributes' do
      it 'locates the requested @post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:invalid_post)
        expect(assigns(:post)).to eq(@post)
      end

      it 'does not changes the @post attributes' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post, title: nil)
        @post.reload
        expect(@post.title).to eq('old post title')
      end

      it 're-renders the edit method' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:invalid_post)
        expect(response).to render_template('edit')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @post = FactoryGirl.create(:post_with_items, user: @user)
    end

    it 'deletes the post' do
      expect{
        delete :destroy, id: @post
      }.to change(Post,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @post
      expect(response).to redirect_to user_manageposts_path
    end
  end

end
