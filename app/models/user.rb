class User < ActiveRecord::Base
  has_many :performances
  has_many :user_roles
  has_many :roles, :through => :user_roles

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def has_role?(role)
    !!self.roles.find_by_name(role)
  end

  def to_producer!
    self.roles << Role.producer
    save!
  end

end
