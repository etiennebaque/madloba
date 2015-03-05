require 'rails_helper'

describe UserPolicy do

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user2) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { UserPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, user)
    end
    it 'does not grant access to a regular user, if it is not this user' do
      expect(subject).not_to permit(user2, user)
    end
    it 'grants access to a regular user, if it is this actual user' do
      expect(subject).to permit(user, user)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, user)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, user)
    end
    it 'does not grant access to a regular user, if it is not this user' do
      expect(subject).not_to permit(user2, user)
    end
    it 'grants access to a regular user, if it is this actual user' do
      expect(subject).to permit(user, user)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, user)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      user.first_name = 'new name'
      expect(subject).to permit(admin, user)
    end
    it 'does not grant update to a regular user, if it is not this user' do
      user.first_name = 'new name'
      expect(subject).not_to permit(user2, user)
    end
    it 'grants update to a regular user, if it is this actual user' do
      user.first_name = 'new name'
      expect(subject).to permit(user, user)
    end
    it 'does not grant update to unsigned user' do
      user.first_name = 'new name'
      expect(subject).not_to permit(unsigned_user, user)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, user)
    end
    it 'does not grant access to any regular user' do
      expect(subject).not_to permit(user, user)
      expect(subject).not_to permit(user2, user)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, user)
    end
  end

  permissions :create? do
    it 'grants creation to admin' do
      expect(subject).to permit(admin, User.new)
    end
    it 'does not grant creation to any regular user' do
      expect(subject).not_to permit(user, User.new)
    end
    it 'does not grant creation to unsigned user' do
      expect(subject).not_to permit(unsigned_user, User.new)
    end
  end

  permissions :destroy? do
    it 'does not grant destroy to admin, if user is this admin' do
      expect(subject).not_to permit(admin, admin.destroy)
    end
    it 'grants destroy to admin only' do
      expect(subject).to permit(admin, user.destroy)
    end
    it 'does not grant destroy to any regular user' do
      expect(subject).not_to permit(user, user.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, user.destroy)
    end
  end
end
