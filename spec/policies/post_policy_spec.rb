require 'rails_helper'

describe PostPolicy, type: :policy do

  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post_with_items, user: user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:unsigned_user) { nil }

  subject { PostPolicy }

  permissions :show? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, post)
    end
    it 'grants access to regular user' do
      expect(subject).to permit(user, post)
    end
    it 'grants access to unsigned user' do
      expect(subject).to permit(unsigned_user, post)
    end
  end

  permissions :edit? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, post)
    end
    it 'does not grant access to regular user, if user does not own post' do
      post.user_id = user.id + 1
      expect(subject).not_to permit(user, post)
    end
    it 'grants access to regular user, if user owns post' do
      post.user_id = user.id
      expect(subject).to permit(user, post)
    end
    it 'does not grant access to unsigned user' do
      expect(subject).not_to permit(unsigned_user, post)
    end
  end

  permissions :update? do
    it 'grants update to admin' do
      post.title = 'updated title'
      expect(subject).to permit(admin, post)
    end
    it 'does not grant update to regular user, if this user does not own post' do
      post.title = 'updated title'
      post.user_id = user.id + 1
      expect(subject).not_to permit(user, post)
    end
    it 'grants update to regular user, if this user owns post' do
      post.title = 'updated title'
      post.user_id = user.id
      expect(subject).to permit(user, post)
    end
    it 'does not grant update to unsigned user' do
      post.title = 'updated title'
      expect(subject).not_to permit(unsigned_user, post)
    end
  end

  permissions :new? do
    it 'grants access to admin' do
      expect(subject).to permit(admin, post)
    end
    it 'grants access to regular user' do
      expect(subject).to permit(user, post)
    end
    it 'grants access to unsigned user' do
      expect(subject).to permit(unsigned_user, post)
    end
  end

  permissions :create? do
    it 'grants creation to admin' do
      expect(subject).to permit(admin, Post.new)
    end
    it 'grants creation to regular user' do
      expect(subject).to permit(user, Post.new)
    end
    it 'grants creation to unsigned user' do
      expect(subject).to permit(unsigned_user, Post.new)
    end
  end

  permissions :destroy? do
    it 'grants destroy to admin' do
      expect(subject).to permit(admin, post.destroy)
    end
    it 'does not grant destroy to regular user, if this user does not own post' do
      post.user_id = user.id + 1
      expect(subject).not_to permit(user, post.destroy)
    end
    it 'grants destroy to regular user, if this user owns post' do
      post.user = user
      expect(subject).to permit(user, post.destroy)
    end
    it 'does not grant destroy to unsigned user' do
      expect(subject).not_to permit(unsigned_user, post.destroy)
    end
  end
end
