class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community
  before_action :set_membership, only: [ :update, :destroy, :approve, :reject ]
  before_action :authorize_admin!, only: [ :approve, :reject, :pending ]

  def create
    # Check if user is already a member
    existing_membership = Current.user.memberships.find_by(community: @community)

    if existing_membership
      redirect_to @community, alert: "You are already a member or have a pending request."
      return
    end

    @membership = Membership.new(
      user: Current.user,
      community: @community,
      role: "member",
      status: @community.private? ? "pending" : "approved"
    )

    if @membership.save
      if @community.private?
        redirect_to @community, notice: "Your membership request has been submitted and is awaiting approval."
      else
        redirect_to @community, notice: "You have successfully joined this community."
      end
    else
      redirect_to @community, alert: "Failed to join the community."
    end
  end

  def update
    if @membership.update(membership_params)
      redirect_to @community, notice: "Membership was successfully updated."
    else
      redirect_to @community, alert: "Failed to update membership."
    end
  end

  def destroy
    @membership.destroy
    redirect_to communities_path, notice: "You have left the community."
  end

  def approve
    if @membership.update(status: "approved")
      redirect_to community_path(@community), notice: "Membership request approved."
    else
      redirect_to community_path(@community), alert: "Failed to approve membership request."
    end
  end

  def reject
    if @membership.update(status: "rejected")
      redirect_to community_path(@community), notice: "Membership request rejected."
    else
      redirect_to community_path(@community), alert: "Failed to reject membership request."
    end
  end

  def pending
    @pending_memberships = @community.memberships.pending
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:role)
  end

  def authorize_admin!
    unless Current.user.admin_of?(@community)
      redirect_to @community, alert: "You don't have permission to perform this action."
    end
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end
end
