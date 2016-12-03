FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :username do |n|
    "tester#{n}"
  end

  factory :user do |f|
    f.first_name 'test'
    f.last_name 'user'
    f.username {generate(:username)}
    f.email {generate(:email)}
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
  end

  factory :user2, class: User do |f|
    f.first_name 'test2'
    f.last_name 'user2'
    f.username {generate(:username)}
    f.email {generate(:email)}
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
  end

  factory :admin, class: User do |f|
    f.first_name 'test'
    f.last_name 'admin'
    f.username {generate(:username)}
    f.email {generate(:email)}
    f.password 'password'
    f.password_confirmation 'password'
    f.confirmed_at Time.now
    f.role 1
  end

  factory :invalid_user, parent: :user do |f|
    f.email nil
  end

end
