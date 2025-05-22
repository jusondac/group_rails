class EventParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community
  before_action :set_event
  before_action :set_participant, only: [ :update, :destroy ]
  before_action :check_access, only: [ :create ]

  def create
    # Check if user is already a participant
    if @event.event_participants.exists?(user: Current.user)
      redirect_to community_event_path(@community, @event), alert: "You are already registered for this event."
      return
    end

    @participant = @event.event_participants.new(user: Current.user, status: params[:status] || "attending")

    if @participant.save
      redirect_to community_event_path(@community, @event), notice: "You have successfully joined this event."
    else
      redirect_to community_event_path(@community, @event), alert: "Failed to join the event."
    end
  end

  def update
    if @participant.update(participant_params)
      redirect_to community_event_path(@community, @event), notice: "Your RSVP status has been updated."
    else
      redirect_to community_event_path(@community, @event), alert: "Failed to update your RSVP status."
    end
  end

  def destroy
    @participant.destroy
    redirect_to community_event_path(@community, @event), notice: "You have left the event."
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end

  def set_event
    @event = @community.events.find(params[:event_id])
  end

  def set_participant
    @participant = @event.event_participants.find(params[:id])

    # Only the user themselves can modify their participation
    unless @participant.user_id == Current.user.id
      redirect_to community_event_path(@community, @event), alert: "You don't have permission to perform this action."
    end
  end

  def participant_params
    params.require(:event_participant).permit(:status)
  end

  def check_access
    unless @event.can_join?(Current.user)
      redirect_to community_event_path(@community, @event), alert: "This is a private event for community members only."
    end
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end
end
