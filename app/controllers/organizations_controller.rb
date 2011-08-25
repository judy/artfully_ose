class OrganizationsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  def index
    if current_user.is_in_organization?
      redirect_to organization_url(current_user.current_organization)
    else
      redirect_to new_organization_url
    end
  end

  def show
    @organization = Organization.find(params[:id])
    authorize! :view, @organization

    @fa_user = FA::User.new
    @kits = @organization.available_kits
  end

  def new
    unless current_user.current_organization.new_record?
      flash[:error] = "You can only join one organization at this time."
      redirect_to organizations_url
    end

    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      @organization.users << current_user
      redirect_to organizations_url, :notice => "#{@organization.name} has been created"
    else
      render :new
    end
  end

  def edit
    @organization = Organization.find(params[:id])
    authorize! :edit, @organization
  end

  def update
    @organization = Organization.find(params[:id])
    authorize! :edit, @organization

    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Successfully updated #{@organization.name}."
      redirect_to @organization
    else
      flash[:error]= "Failed to update #{@organization.name}."
      render :show
    end
  end

  def destroy
  end

  def tax_info
    @organization = Organization.find(params[:id])
    authorize! :edit, @organization

    unless @organization.update_tax_info(params[:organization])
      flash[:error] = @organization.errors.full_messages.to_sentence
    end

    redirect_to :back and return if params[:back]
  end

  def connect
    @organization = Organization.find(params[:id])
    authorize! :view, @organization
    @fa_user = FA::User.new(params[:fa_user])
    @kits = @organization.available_kits

    if @fa_user.authenticate
      @organization.update_attribute(:fa_member_id, @fa_user.member_id)
      flash[:notice] = "Successfully connected to Fractured Atlas!"
      if params[:back]
        redirect_to :back
      else
        redirect_to @organization
      end
    else
      flash[:error]= "Unable to connect to your Fractured Atlas account."
      if params[:back]
        redirect_to :back
      else
        render :show
      end
    end
  end

end
