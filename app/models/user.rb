class User < ActiveRecord::Base

  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :first_name, :last_name, :username, presence: true
  validates_uniqueness_of :username

  has_many :locations, dependent: :destroy
  has_many :posts, dependent: :destroy

  def owns_post (post)
    self.posts.include?(post)
  end
end
