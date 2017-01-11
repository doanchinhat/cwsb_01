class DirectliesController < ApplicationController
  before_action :load_venue
  before_action :load_payment_method, only: [:edit, :update]
  before_action :load_directly, only: [:edit, :update]

  def create
    @directly = Directly.new directly_params
    if @directly.save
      flash[:success] = t "payment_methods.create_success"
    else
      flash[:alert] = t "payment_methods.create_fail"
    end
    redirect_to edit_venue_venue_market_path
  end

  def edit
  end

  def update
    if @directly.update_attributes directly_params
      flash[:success] = t ".update_directly_success"
    else
      flash[:error] = t ".update_directly_fail"
    end
    redirect_to edit_venue_venue_market_path
  end

  private
  def load_venue
    @venue = Venue.find_by id: params[:venue_id]
    unless @venue
      flash[:danger] = t "venue.not_found"
      redirect_to venues_path
    end
  end

  def load_directly
    @directly = Directly.find_by id: params[:id]
    unless @directly
      flash[:danger] = t ".directly_not_found"
      redirect_to edit_venue_venue_market_path
    end
  end

  def load_payment_method
    @payment_method = @venue.payment_methods.find_by payment_type: Settings.payment_methods.directly
    unless @payment_method
      flash[:danger] = t ".payment_method_not_found"
    end
  end

  def directly_params
    params.require(:directly).permit(:id, :name, :address, :phone_number,
      :message, :day, :hour, :verified).merge! venue: @venue,
      pending_time: Common.convert_hour(params[:directly][:day].to_i, params[:directly][:hour].to_i)
  end
end
