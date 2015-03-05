require 'rails_helper'

RSpec.describe User::AdsController, :type => :controller do

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

    @item = FactoryGirl.create(:item)
    @item.category = FactoryGirl.create(:category)
    @item.save

    @location = FactoryGirl.create(:location, user_id: @user.id)
    @location.save

    sign_in @user
  end

  describe 'GET #show' do
    it 'assigns the requested ad to @ad' do
      ad = FactoryGirl.create(:ad, user: @user)
      get :show, id: ad.id
      expect(assigns(:ad)).to eq(ad)
    end

    it 'renders the right view' do
      ad = FactoryGirl.create(:ad, user: @user)
      get :show, id: ad.id
      expect(response).to render_template('show')
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested item to @ad' do
      ad = FactoryGirl.create(:ad, user: @user)
      get :edit, id: ad.id
      expect(assigns(:ad)).to eq(ad)
    end

    it 'renders the right view' do
      ad = FactoryGirl.create(:ad, user: @user)
      get :edit, id: ad.id
      expect(response).to render_template('edit')
    end
  end

  describe 'GET #new' do
    it 'instantiates a new @item' do
      get :new
      expect(assigns(:ad)).to be_a_new(Ad)
    end

    it 'renders the right view' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        # TODO: manage to correctly initialize @ad, so that #create test passes.
        @ad = FactoryGirl.attributes_for(:ad, user_id: @user.id, item_id: @item.id, location_id: @location.id)
      end

      it 'creates a new ad' do
        expect{
          post :create, ad: @ad
        }.to change(Ad,:count).by(1)
      end

      it 'redirects to the new ad' do
        post :create, ad: @ad
        expect(response).to redirect_to :action => :show, :id => assigns(:ad).id
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new ad' do
        expect {
          post :create, ad: FactoryGirl.attributes_for(:invalid_ad, user: @user, item: FactoryGirl.create(:item), location: FactoryGirl.create(:location))
        }.to_not change(Ad,:count)
      end

      it 're-renders the new method' do
        post :create, ad: FactoryGirl.attributes_for(:invalid_item)
        expect(response).to render_template('new')
      end

    end
  end

  describe 'PUT #update' do
    before :each do
      @ad = FactoryGirl.create(:ad, user: @user, title: 'old ad title')
    end

    context 'with valid attributes' do
      it 'locates the requested @ad' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:ad)
        expect(assigns(:ad)).to eq(@ad)
      end

      it 'changes the @ad attributes' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:ad, name: 'new ad title')
        @ad.reload
        expect(@ad.title).to eq('new ad title')
      end

      it 'redirects to the updated @ad' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:ad)
        expect(response).to redirect_to :action => :edit, :id => assigns(:ad).id
      end
    end

    context 'with invalid attributes' do
      it 'locates the requested @ad' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:invalid_ad)
        expect(assigns(:ad)).to eq(@ad)
      end

      it 'does not changes the @ad attributes' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:ad, title: nil)
        @ad.reload
        expect(@ad.title).to eq('old ad title')
      end

      it 're-renders the edit method' do
        put :update, id: @ad, ad: FactoryGirl.attributes_for(:invalid_ad)
        expect(response).to render_template('edit')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @ad = FactoryGirl.create(:ad, user: @user)
    end

    it 'deletes the ad' do
      expect{
        delete :destroy, id: @ad
      }.to change(Ad,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @ad
      expect(response).to redirect_to user_managerecords_path
    end
  end

end
