require 'rails_helper'

RSpec.describe User::LocationsController, :type => :controller do

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

  def test_show_edit_requested_location
    location = FactoryGirl.create(:location)

    get :show, id: location
    expect(assigns(:location)).to eq(location)
  end

  def test_render_location_view
    get :show, id: FactoryGirl.create(:location)
    expect(response).to render_template('location')
  end

  describe 'GET #show' do
    it 'assigns the requested location to @location' do
      test_show_edit_requested_location
    end

    it 'renders the right view' do
      test_render_location_view
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested location to @location' do
      test_show_edit_requested_location
    end

    it 'renders the right view' do
      test_render_location_view
    end
  end

  describe 'GET #new' do
    it 'instantiates a new @location' do
      get :new
      expect(assigns(:location)).to be_a_new(Location)
    end

    it 'renders the right view' do
      test_render_location_view
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new location' do
        expect{
          post :create,
               location: FactoryGirl.attributes_for(:location)
        }.to change(Location,:count).by(1)
      end

      it 'redirects to the new location' do
        post :create, location: FactoryGirl.attributes_for(:location)
        expect(response).to redirect_to :action => :edit, :id => assigns(:location).id
      end

    end

    context 'with invalid attributes' do
      it 'does not save the new location' do
        expect {
          post :create, location: FactoryGirl.attributes_for(:invalid_location)
        }.to_not change(Location,:count)
      end

      it 're-renders the new method' do
        post :create, location: FactoryGirl.attributes_for(:invalid_location)
        expect(response).to render_template('location')
      end

    end
  end

  describe 'PUT #update' do
    before :each do
      @location = FactoryGirl.create(:location, name: 'old location name')
    end

    context 'with valid attributes' do
      it 'locates the requested @location' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:location)
        expect(assigns(:location)).to eq(@location)
      end

      it 'changes the @location attributes' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:location, name: 'new location name')
        @location.reload
        expect(@location.name).to eq('new location name')
      end

      it 'redirects to the updated @location' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:location)
        expect(response).to redirect_to :action => :edit, :id => assigns(:location).id
      end
    end

    context 'with invalid attributes' do
      it 'locates the requested @location' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:invalid_location)
        expect(assigns(:location)).to eq(@location)
      end

      it 'does not changes the @location attributes' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:location, name: nil)
        @location.reload
        expect(@location.name).not_to eq('new location name')
      end

      it 're-renders the edit method' do
        put :update, id: @location, location: FactoryGirl.attributes_for(:invalid_location)
        expect(response).to render_template('location')
      end
    end

  end

  describe 'DELETE #destroy' do
    before :each do
      @location = FactoryGirl.create(:location)
    end

    it 'deletes the location' do
      expect{
        delete :destroy, id: @location
      }.to change(Location,:count).by(-1)
    end

    it 'redirects to the record page' do
      delete :destroy, id: @location
      expect(response).to redirect_to user_managerecords_path
    end
  end

end
