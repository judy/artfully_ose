class Organization < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :kits, :after_add => lambda { |u,k| k.activate! unless k.activated? }

  validates_presence_of :name
end