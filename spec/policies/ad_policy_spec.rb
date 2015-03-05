require 'rails_helper'

describe AdPolicy do

  let(:user) { FactoryGirl.create(:user) }
  let(:ad) { FactoryGirl.create(:ad, user: user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { AdPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, ad)
    end
    it 'grants access to regular user' do
      expect(subject).to permit(user, ad)
    end
    it 'grants access to unsigned user' do
      expect(subject).to permit(unsigned_user, ad)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, ad)
    end
    it 'does not grant access to regular user, if user does not own ad' do
      ad.user_id = user.id + 1
      expect(subject).not_to permit(user, ad)
    end
    it 'grants access to regular user, if user owns ad' do
      ad.user_id = user.id
      expect(subject).to permit(user, ad)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, ad)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      ad.title = 'updated title'
      expect(subject).to permit(admin, ad)
    end
    it 'does not grant update to regular user, if this user does not own ad' do
      ad.title = 'updated title'
      ad.user_id = user.id + 1
      expect(subject).not_to permit(user, ad)
    end
    it 'grants update to regular user, if this user owns ad' do
      ad.title = 'updated title'
      ad.user_id = user.id
      expect(subject).to permit(user, ad)
    end
    it 'does not grant update to unsigned user' do
      ad.title = 'updated title'
      expect(subject).not_to permit(unsigned_user, ad)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, ad)
    end
    it 'grants access to regular user' do
      expect(subject).to permit(user, ad)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, ad)
    end
  end

  permissions :create? do
    it 'grants creation to admin' do
      expect(subject).to permit(admin, Ad.new)
    end
    it 'grants creation to regular user' do
      expect(subject).to permit(user, Ad.new)
    end
    it 'does not grant creation to unsigned user' do
      expect(subject).not_to permit(unsigned_user, Ad.new)
    end
  end

  permissions :destroy? do
    it 'grants destroy to admin' do
      expect(subject).to permit(admin, ad.destroy)
    end
    it 'does not grant destroy to regular user, if this user does not own ad' do
      ad.user_id = user.id + 1
      expect(subject).not_to permit(user, ad.destroy)
    end
    it 'grants destroy to regular user, if this user owns ad' do
      ad.user = user
      expect(subject).to permit(user, ad.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, ad.destroy)
    end
  end
end
