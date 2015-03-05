require 'rails_helper'

describe CategoryPolicy do

  let(:user) { FactoryGirl.create(:user) }
  let(:category) { FactoryGirl.create(:category) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { CategoryPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, category)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, category)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, category)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, category)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, category)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, category)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      category.name = 'updated name'
      expect(subject).to permit(admin, category)
    end
    it 'does not grant update to regular user' do
      category.name = 'updated name'
      expect(subject).not_to permit(user, category)
    end
    it 'does not grant update to unsigned user' do
      category.name = 'updated name'
      expect(subject).not_to permit(unsigned_user, category)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, category)
    end
    it 'does not grant access to regular user' do
      expect(subject).not_to permit(user, category)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, category)
    end
  end

  permissions :create? do
    it 'grants creation to admin' do
      expect(subject).to permit(admin, Category.new)
    end
    it 'does not grant creation to regular user' do
      expect(subject).not_to permit(user, Category.new)
    end
    it 'does not grant creation to unsigned user' do
      expect(subject).not_to permit(unsigned_user, Category.new)
    end
  end

  permissions :destroy? do
    it 'grants destroy to admin' do
      expect(subject).to permit(admin, category.destroy)
    end
    it 'does not grant destroy to regular user' do
      expect(subject).not_to permit(user, category.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, category.destroy)
    end
  end
end
