FactoryGirl.define do

  factory :user do |f|
    f.first_name 'test'
    f.last_name 'user'
    f.username 'test_user'
    f.email 'user@example.com'
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
  end

  factory :user2, class: User do |f|
    f.first_name 'test2'
    f.last_name 'user2'
    f.username 'test2_user2'
    f.email 'user2@example.com'
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
  end

  factory :admin, class: User do |f|
    f.first_name 'test'
    f.last_name 'admin'
    f.username 'test_admin'
    f.email 'admin@example.com'
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
    f.role 1
  end

  factory :invalid_user, parent: :user do |f|
    f.email nil
  end

end
