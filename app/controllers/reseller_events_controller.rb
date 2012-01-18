class ResellerEventsController < ApplicationController

  before_filter :find_reseller_profile
  before_filter :adjust_datetime_to_organization_time_zone
  before_filter :authorize_reseller_profile, :except => :index
  before_filter :find_reseller_event, :only => [ :edit, :update, :destroy ]

  def index
    @reseller_events = current_user.current_organization.reseller_events.upcoming.chronological
  end

  def new
    @reseller_event = ResellerEvent.new
  end

  def create
    @reseller_event = ResellerEvent.new(params[:reseller_event])
    @reseller_event.reseller_profile = @reseller_profile

    if @reseller_event.save
      flash[:notice] = "Your new reseller event has been created."
      redirect_to organization_reseller_events_path(@organization)
    else
      flash.now[:error] = "There was an error while creating your new reseller event."
      render :new
    end
  end

  def edit
  end

  def update
    if @reseller_event.update_attributes(params[:reseller_event])
      flash[:notice] = "Your reseller event has been updated."
      redirect_to organization_reseller_events_path(@organization)
    else
      flash.now[:error] = "There was an error in updating your reseller event."
      render :edit
    end
  end

  def destroy
    @reseller_event.destroy

    redirect_to organization_reseller_events_path(@organization)
  end

  protected

  def find_reseller_profile
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    if @reseller_profile.nil?
      flash[:error] = "You do not have a reseller profile."
      redirect_to root_path
    end
  end

  def adjust_datetime_to_organization_time_zone
    if params[:reseller_event] && params[:reseller_event][:datetime].present?
      datetime = params[:reseller_event][:datetime]
      time_zone = @organization.time_zone
      datetime = ActiveSupport::TimeZone.create(time_zone).parse(datetime)
      params[:reseller_event][:datetime] = datetime
    end
  end

  def authorize_reseller_profile
    authorize! :manage, @reseller_profile
  end

  def find_reseller_event
    @reseller_event = @reseller_profile.reseller_events.find(params[:id])
  end

end
