class Order < ApplicationRecord
  after_create :update_booking

  attr_accessor :booking_ids

  belongs_to :coupon
  belongs_to :venue, -> {with_deleted}
  belongs_to :user
  belongs_to :payment_detail, polymorphic: true

  has_one :paypal

  has_many :bookings, dependent: :destroy
  has_many :directly

  enum status: {requested: 0, pending: 1, paid: 2, closed: 3}

  scope :have_order_payment_directly, -> do
    where payment_detail_type: UserPaymentDirectly.name
  end
  scope :have_order_payment_banking, -> do
    where payment_detail_type: UserPaymentBanking.name
  end
  scope :recent, ->{order :created_at}

  scope :filter_by_payment_detail, ->payment_detail_type do
    where payment_detail_type: payment_detail_type if payment_detail_type.present?
  end
  scope :filter_by_status, ->status do
    where status: status if status.present?
  end

  after_update :delete_paypal_after_change_method
  after_update :checktime_to_reject

  def delete_paypal_after_change_method
    if self.payment_detail_type != Paypal
      self.paypal.destroy if self.paypal
    end
  end

  def update_booking
    @booking_ids = booking_ids.split(" ")
    @booking_ids.each do |booking_id|
      booking = Booking.find_by id: booking_id
      booking.update_attributes order_id: self.id, state: "requested"
    end
  end

  def auto_reject_order
    if self.payment_detail_type && self.payment_detail_type != Settings
      .payment_methods_filter.paypal && self.status != Order.statuses[:paid]
      date = self.updated_at + self.payment_detail.pending_time.hours
      if date > Time.current
        self.bookings.each do |booking|
          booking.update_attributes state: Booking.states[:rejected]
        end
        self.update_attributes status: Order.statuses[:closed]
      end
    end
  end

  def checktime_to_reject
    delay(run_at: Common.mul_60(self.payment_detail.pending_time).minutes.from_now)
      .auto_reject_order
  end

  def load_email_paypal
    self.venue.payment_methods.paypal.find_by is_chosen: true
  end

  def find_payment_banking
    self.venue.payment_methods.banking
  end

  def find_payment_directly
    self.venue.payment_methods.directly
  end

  def find_information_banking_account
    self.venue.banking.find_by verified: true
  end

  def find_directly_info
    self.venue.directly.find_by verified: true
  end
end
