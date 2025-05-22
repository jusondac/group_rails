class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @upcoming_events = @community.events.upcoming
    @past_events = @community.events.past
    @user_is_member = Current.user.member_of?(@community)
    @user_is_admin = Current.user.admin_of?(@community)
  end

  def show
    @is_participant = @event.users.include?(Current.user)
    @participant = @event.event_participants.find_by(user: Current.user)
    @attendees = @event.attendees
    @can_join = @event.can_join?(Current.user)
  end

  def new
    @event = @community.events.new
  end

  def create
    @event = @community.events.new(event_params)
    @event.created_by = Current.user

    if @event.save
      # Add creator as participant
      @event.event_participants.create(user: Current.user, status: "attending")
      redirect_to community_event_path(@community, @event), notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to community_event_path(@community, @event), notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to community_events_path(@community), notice: "Event was successfully deleted."
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def set_event
    @event = @community.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :start_date, :end_date, :location, :private)
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
