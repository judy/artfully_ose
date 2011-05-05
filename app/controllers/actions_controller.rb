class ActionsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def new
    @action = AthenaAction.new
    @person = AthenaPerson.find params[:person_id]

    @action.creator = nil
    @action.occurred_at = DateTime.now.in_time_zone(current_user.current_organization.time_zone)
  end

  def edit
    @action = AthenaAction.find params[:id]
    @person = AthenaPerson.find params[:person_id]

    @action.creator = User.find( @action.creator_id ).email
    #strip time zone from time before displaying it
    #the correct time zone will be re-attached by the prepare_attr! method
    org = current_user.current_organization
    @action.occurred_at = @action.occurred_at.in_time_zone(org.time_zone)
    hour = @action.occurred_at.hour
    min = @action.occurred_at.min
    @action.occurred_at = @action.occurred_at.to_date.to_datetime.change(:hour=>hour, :min=>min)
  end

  def create
    @person = AthenaPerson.find params[:person_id]

    @action = AthenaAction.create_of_type(params[:action_type])
    @action.set_params(params[:athena_action][:athena_action], @person, current_user)

    if @action.valid? && @action.save!
      flash[:notice] = "Action logged successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "One or more fields are invalid!"
      redirect_to :back
    end
    
  end

  def update
    @person = AthenaPerson.find params[:person_id]

    @action = AthenaAction.find params[:id]
    @action.set_params(params[:athena_action][:athena_action], @person, current_user)

    if @action.valid? && @action.save!
      flash[:notice] = "Action updated successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "One or more fields are invalid!"
      redirect_to :back
    end

  end

end
