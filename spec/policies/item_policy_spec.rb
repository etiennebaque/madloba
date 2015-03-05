require 'rails_helper'

describe ItemPolicy do

  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { ItemPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, item)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, item)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, item)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, item)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, item)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, item)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, item)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      item.name = 'updated name'
      expect(subject).to permit(admin, item)
    end
    it 'does not grant update to regular user' do
      item.name = 'updated name'
      expect(subject).not_to permit(user, item)
    end
    it 'does not grant update to unsigned user' do
      item.name = 'updated name'
      expect(subject).not_to permit(unsigned_user, item)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, item)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, item)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, item)
    end
  end

  permissions :create? do
    it 'grants creation to admin' do
      expect(subject).to permit(admin, Item.new)
    end
    it 'does not grant creation to regular user' do
      expect(subject).not_to permit(user, Item.new)
    end
    it 'does not grant creation to unsigned user' do
      expect(subject).not_to permit(unsigned_user, Item.new)
    end
  end

  permissions :destroy? do
    it 'grants destroy to admin' do
      expect(subject).to permit(admin, item.destroy)
    end
    it 'does not grant destroy to regular user' do
      expect(subject).not_to permit(user, item.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, item.destroy)
    end
  end
end
