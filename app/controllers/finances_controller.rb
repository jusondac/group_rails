class FinancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community
  before_action :authorize_admin!

  def show
    @finance_setting = @community.finance_setting || @community.build_finance_setting
    @members = @community.memberships.approved.includes(:user, :payments)
    @total_members = @members.count
    @total_pending = @community.payments.pending.count
    @total_paid = @community.payments.paid.count
    @total_overdue = @community.payments.overdue.count

    # Calculate total collected
    @total_collected = @community.payments.paid.sum(:amount)
  end

  def create
    @finance_setting = @community.build_finance_setting(finance_params)

    if @finance_setting.save
      redirect_to community_finance_path(@community), notice: "Finance settings have been created."
    else
      @members = @community.memberships.approved.includes(:user, :payments)
      render :show, status: :unprocessable_entity
    end
  end

  def update
    @finance_setting = @community.finance_setting

    if @finance_setting.update(finance_params)
      redirect_to community_finance_path(@community), notice: "Finance settings have been updated."
    else
      @members = @community.memberships.approved.includes(:user, :payments)
      render :show, status: :unprocessable_entity
    end
  end

  def payments
    @memberships = @community.memberships.approved.includes(:user, :payments)
    @pending_payments = @community.payments.pending.includes(membership: :user)
    @paid_payments = @community.payments.paid.includes(membership: :user)
    @overdue_payments = @community.payments.overdue.includes(membership: :user)
    @is_admin = Current.user.admin_of?(@community)
  end

  def generate_payments
    if !@community.has_finance_enabled?
      redirect_to community_finance_path(@community), alert: "Finance settings must be enabled to generate payments."
      return
    end

    count = @community.generate_payments

    if count > 0
      redirect_to payments_community_finance_path(@community), notice: "#{count} payments have been generated for members."
    else
      # Check why no payments were generated
      if @community.memberships.approved.empty?
        message = "No approved members found. Add members to the community first."
      elsif @community.memberships.approved.all? { |m| m.payments.pending.or(m.payments.paid).exists? }
        message = "No new payments were generated. All members already have pending or paid payments."
      else
        message = "No new payments were generated. Please check the logs for more details."
      end

      redirect_to payments_community_finance_path(@community), alert: message
    end
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def finance_params
    params.require(:finance_setting).permit(:amount, :frequency, :active)
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end

  def authorize_admin!
    unless Current.user.admin_of?(@community)
      redirect_to community_path(@community), alert: "You don't have permission to access finance settings."
    end
  end
end
