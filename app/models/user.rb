class User < ApplicationRecord
  include RecordFindingByTime
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable,:omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  has_one :image
  has_many :bookings
  has_many :reviews
  has_many :invoices, through: :bookings
  has_many :notifications
  has_many :user_role_venues
  has_many :roles, through: :user_role_venues
  has_many :venues, through: :user_role_venues
  has_many :orders, through: :venues
  has_many :user_payment_bankings
  has_many :user_payment_directlies

  def self.from_omniauth auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.name = auth.info.name
      user.password = Devise.friendly_token[8,16]
      user.skip_confirmation!
    end
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
