class CommunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin!, only: [ :edit, :update, :destroy ]

  def index
    @communities = Community.public_communities
    @my_communities = Current.user.communities.distinct
  end

  def show
    @is_member = Current.user.member_of?(@community)
    @is_admin = Current.user.admin_of?(@community)
    @membership = Current.user.memberships.find_by(community: @community)
    @pending_memberships = @community.memberships.pending if @is_admin

    # Get members count and list of members
    @members_count = @community.memberships.approved.count
    @members = @community.memberships.approved.includes(:user).limit(10)

    # Get upcoming events
    @upcoming_events = @community.events.where("start_date > ?", Time.current).order(start_date: :asc).limit(3)

    unless @community.public? || @is_member || @is_admin
      redirect_to communities_path, alert: "You don't have access to this private community"
    end
  end

  def new
    @community = Community.new
  end

  def create
    @community = Community.new(community_params)

    if @community.save
      # Create membership for creator as admin with approved status
      Membership.create(
        user: Current.user,
        community: @community,
        role: "admin",
        status: "approved"
      )
      redirect_to @community, notice: "Community was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @community.update(community_params)
      redirect_to @community, notice: "Community was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @community.destroy
    redirect_to communities_path, notice: "Community was successfully deleted."
  end

  private

  def set_community
    @community = Community.find(params[:id])
  end

  def community_params
    params.require(:community).permit(:name, :description, :private)
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
