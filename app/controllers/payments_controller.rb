class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment
  before_action :authorize_admin!

  def mark_as_paid
    if @payment.mark_as_paid!
      redirect_back(fallback_location: root_path, notice: "Payment has been marked as paid.")
    else
      redirect_back(fallback_location: root_path, alert: "Failed to mark payment as paid.")
    end
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
    @community = @payment.membership.community
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end

  def authorize_admin!
    unless Current.user.admin_of?(@community)
      redirect_to community_path(@community), alert: "You don't have permission to perform this action."
    end
  end
end
