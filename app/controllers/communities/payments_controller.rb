class Communities::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community
  before_action :authorize_admin!

  def create
    @payment = Payment.new(payment_params)
    @payment.membership = Membership.find(params[:membership_id])
    @payment.community = @community
    
    if @payment.save
      redirect_to community_finance_path(@community), notice: "Payment was successfully created."
    else
      redirect_to community_finance_path(@community), alert: @payment.errors.full_messages.to_sentence
    end
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def payment_params
    params.permit(:membership_id, :amount, :due_date, :status)
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end

  def authorize_admin!
    unless Current.user.admin_of?(@community)
      redirect_to community_path(@community), alert: "You do not have permission to perform this action."
    end
  end
end
