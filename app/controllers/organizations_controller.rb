class OrganizationsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    @organizations = current_user.organizations || []
  end

  def show
    @organization = Organization.find(params[:id])
    authorize! :view, @organization
    @kits = @organization.kits
  end

  def new
    unless current_user.current_organization.new_record?
      flash[:error] = "You can only join one organization at this time."
      redirect_to organizations_url
    end

    @organization = Organization.new
    #@organization.time_zone
  end

  def create
    @organization = Organization.new(params[:organization][:organization])

    if @organization.save
      @organization.users << current_user
      redirect_to organizations_url, :notice => "#{@organization.name} has been created"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end