require 'rails_helper'

RSpec.describe User::CategoriesController, :type => :controller do

  before :each do
    # Making sure we're not redirected to the setup screens.
    setting = Setting.find_by_key('setup_step')
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
    it 'assigns the requested category to @category' do
      category = FactoryGirl.create(:category)
      get :show, id: category.id
      expect(assigns(:category)).to eq(category)
    end

    it 'renders the right view' do
      get :show, id: FactoryGirl.create(:category)
      expect(response).to render_template('category')
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested category to @category' do
      category = FactoryGirl.create(:category)
      get :edit, id: category.id
      expect(assigns(:category)).to eq(category)
    end

    it 'renders the right view' do
      get :edit, id: FactoryGirl.create(:category)
      expect(response).to render_template('category')
    end
  end

  describe 'GET #new' do
    it 'instantiates a new @category' do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
    end

    it 'renders the right view' do
      get :new
      expect(response).to render_template('category')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        @category = FactoryGirl.attributes_for(:category)
      end

      it 'creates a new category' do
        expect{
          post :create, category: @category
        }.to change(Category,:count).by(1)
      end

      it 'redirects to the new category' do
        post :create, category: @category
        expect(response).to redirect_to :action => :edit, :id => assigns(:category).id
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new category' do
        expect {
          post :create, category: FactoryGirl.attributes_for(:invalid_category)
        }.to_not change(Category,:count)
      end

      it 're-renders the new method' do
        post :create, category: FactoryGirl.attributes_for(:invalid_category)
        expect(response).to render_template('category')
      end

    end
  end

  describe 'PUT #update' do
    before :each do
      @category = FactoryGirl.create(:category, name: 'old category name')
    end

    context 'with valid attributes' do
      it 'locates the requested @category' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:category)
        expect(assigns(:category)).to eq(@category)
      end

      it 'changes the @category attributes' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:category, name: 'new category name')
        @category.reload
        expect(@category.name).to eq('new category name')
      end

      it 'redirects to the updated @category' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:category)
        expect(response).to redirect_to :action => :edit, :id => assigns(:category).id
      end
    end

    context 'with invalid attributes' do
      it 'locates the requested @category' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:invalid_category)
        expect(assigns(:category)).to eq(@category)
      end

      it 'does not changes the @category attributes' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:category, name: nil)
        @category.reload
        expect(@category.name).not_to eq('new category name')
      end

      it 're-renders the edit method' do
        put :update, id: @category, category: FactoryGirl.attributes_for(:invalid_category)
        expect(response).to render_template('category')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @category = FactoryGirl.create(:category)
    end

    it 'deletes the category' do
      expect{
        delete :destroy, id: @category
      }.to change(Category,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @category
      expect(response).to redirect_to user_managerecords_path
    end
  end

end
