require 'rails_helper'

describe LocationPolicy do

  let(:user) { FactoryGirl.create(:user) }
  let(:location) { FactoryGirl.create(:location) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { LocationPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, location)
    end
    it 'does not grant access to regular user, if user does not own location' do
      location.user_id = user.id + 1
      expect(subject).not_to permit(user, location)
    end
    it 'grants access to regular user, if user owns location' do
      location.user_id = user.id
      expect(subject).to permit(user, location)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, location)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, location)
    end
    it 'does not grant access to regular user, if user does not own location' do
      location.user_id = user.id + 1
      expect(subject).not_to permit(user, location)
    end
    it 'grants access to regular user, if user owns location' do
      location.user_id = user.id
      expect(subject).to permit(user, location)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, location)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      location.name = 'updated name'
      expect(subject).to permit(admin, location)
    end
    it 'does not grant update to regular user, if user does not own location' do
      location.name = 'updated name'
      location.user_id = user.id + 1
      expect(subject).not_to permit(user, location)
    end
    it 'grants update to regular user, if user owns location' do
      location.name = 'updated name'
      location.user_id = user.id
      expect(subject).to permit(user, location)
    end
    it 'does not grant update to unsigned user' do
      location.name = 'updated name'
      expect(subject).not_to permit(unsigned_user, location)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, location)
    end
    it 'grant access to regular user' do
      expect(subject).to permit(user, location)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, location)
    end
  end

  permissions :create? do
    it 'grants creation to admin only' do
      expect(subject).to permit(admin, Location.new)
    end
    it 'grants creation to regular user' do
      expect(subject).to permit(user, Location.new)
    end
    it 'does not grant creation to unsigned user' do
      expect(subject).not_to permit(unsigned_user, Location.new)
    end
  end

  permissions :destroy? do
    it 'grants destroy to admin only' do
      expect(subject).to permit(admin, location.destroy)
    end
    it 'does not grant destroy to regular user, if user does not own location' do
      location.user_id = user.id + 1
      expect(subject).not_to permit(user, location.destroy)
    end
    it 'grants destroy to regular user, if user owns location' do
      location.user_id = user.id
      expect(subject).to permit(user, location.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, location.destroy)
    end
  end
end
