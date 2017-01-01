RSpec.describe UserMailer do
  describe 'created_post' do
    let (:user) do
      {email: Faker::Internet.email, name: Faker::Name.first_name, is_anon: false}
    end
    let (:post) {FactoryGirl.build_stubbed(:post)}
    let (:url) {Faker::Internet.url}

    let (:mailer) {UserMailer.created_post(user, post, url)}

    it 'send an email' do
      expect { mailer.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mailer.to).to eq([user[:email]])
    end
  end

  describe 'send_message_for_post' do
    let (:user) do
      {full_name: Faker::Name.first_name, email: Faker::Internet.email}
    end
    let (:message) {'test message'}
    let (:post) {FactoryGirl.build_stubbed(:post)}
    let (:post_info) do
      {title: post.title, first_name: post.user.first_name, email: post.user.email}
    end

    let (:mailer) {UserMailer.send_message_for_post(user, message, post_info)}

    it 'send an email' do
      expect { mailer.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mailer.to).to eq([post_info[:email]])
    end
  end

end