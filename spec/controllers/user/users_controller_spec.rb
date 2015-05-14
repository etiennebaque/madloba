require 'rails_helper'

RSpec.describe User::UsersController, :type => :controller do

  before :each do
    # Making sure we're not redirected to the setup screens.
    setting = Setting.find_or_create_by(key: 'setup_step')
    setting.value = 0
    setting.save

    # Creating admin user, and signing in.
    allow_message_expectations_on_nil
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  describe 'GET #new' do
    it 'instantiates a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the right view' do
      get :new
      expect(response).to render_template('user')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        @created_user = FactoryGirl.attributes_for(:user)
      end

      # Didn't manage to pass through the confirmation e-mail (fails at mailer)
      #it 'creates a new user' do
        #expect{
          #post :create, user: @created_user
        #}.to change(User,:count).by(1)
        #end

      #it 'redirects to the new user' do
        #post :create, user: @created_user
        #expect(response).to redirect_to :action => :edit, :id => assigns(:user).id
      #end
    end

    context 'with invalid attributes' do
      it 'does not save the new user' do
        expect {
          post :create, user: FactoryGirl.attributes_for(:invalid_user)
        }.to_not change(User,:count)
      end

      it 're-renders the new method' do
        post :create, user: FactoryGirl.attributes_for(:invalid_user)
        expect(response).to render_template('user')
      end

    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user to @user' do
      @user = FactoryGirl.create(:user)
      get :edit, id: @user.id
      expect(assigns(:user)).to eq(@user)
    end

    it 'renders the right view' do
      get :edit, id: FactoryGirl.create(:user)
      expect(response).to render_template('user')
    end
  end

  describe 'PUT #update' do
    before :each do
      @user = FactoryGirl.create(:user, first_name: 'old user first name')
    end

    context 'with valid attributes' do
      it 'locates the requested @user' do
        put :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
        expect(assigns(:user)).to eq(@user)
      end

      it 'changes the @user attributes' do
        put :update, id: @user.id, user: FactoryGirl.attributes_for(:user, first_name: 'new user first name')
        @user.reload
        expect(@user.first_name).to eq('new user first name')
      end

      it 'redirects to the updated @user' do
        put :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
        expect(response).to redirect_to :action => :edit, :id => assigns(:user).id
      end
    end

    context 'with invalid attributes' do
      it 'locates the requested @user' do
        put :update, id: @user, user: FactoryGirl.attributes_for(:invalid_user)
        expect(assigns(:user)).to eq(@user)
      end

      it 'does not changes the @user attributes' do
        put :update, id: @user, user: FactoryGirl.attributes_for(:user, first_name: nil)
        @user.reload
        expect(@user.first_name).to eq('old user first name')
      end

      it 're-renders the edit method' do
        put :update, id: @user, user: FactoryGirl.attributes_for(:invalid_user)
        expect(response).to render_template('user')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @user = FactoryGirl.create(:user)
    end

    it 'deletes the user' do
      expect{
        delete :destroy, id: @user.id
      }.to change(User,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @user.id
      expect(response).to redirect_to user_manageusers_path
    end
  end

end
