class Price < ApplicationRecord
  acts_as_paranoid

  belongs_to :space
  belongs_to :booking_type

  validates_numericality_of :price, greater_than_or_equal_to: 0, allow_nil: true
  before_save :nil_to_zero

  delegate :name, to: :booking_type, prefix: true, allow_nil: true

  def nil_to_zero
    unless price
      self.price = 0
    end
  end
end
