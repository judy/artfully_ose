class MembershipsController < ActionController::Base
  protect_from_forgery

  def new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @organization = Organization.find(params[:organization_id])
    authorize! :manage, @organization

    with_user do |user|
      build_membership(user, @organization) or build_errors(user, @organization)
    end

    if current_user.is_admin?
      redirect_to admin_organization_url(@organization) and return
    else
      redirect_to organization_url(@organization) and return
    end
  end

  def destroy
    @organization = Organization.find(params[:organization_id])
    @mship = Membership.find(params[:id])
    authorize! :manage, @organization
    @mship.destroy
    if current_user.is_admin?
      redirect_to admin_organization_url(@organization), :notice => "User has been removed from #{@organization.name}" and return
    else
      redirect_to organization_url(@organization), :notice => "User has been removed from #{@organization.name}" and return
    end
  end

  private

    def build_membership(user, organization)
      membership = Membership.find_by_user_id_and_organization_id(user.id, organization.id)
      return false unless membership.nil? and !user.memberships.any?

      @membership = organization.memberships.build(:user => user)
      if @membership.save
        flash[:notice] = "#{user.email} has been added successfully."
      else
        flash[:error] = "User #{user.email} could not been added."
      end

      return true
    end

    def build_errors(user, organization)
      if user.organizations.first == organization
        flash[:alert] = "#{user.email} is already a member of this organization."
      else
        flash[:error] = "User #{params[:user_email]} is already a member of another organization."
      end
    end

    def with_user(&block)
      flash[:error] = "You must specify an email" and return if params[:user_email].blank?
      user = User.find_by_email(params[:user_email])
      flash[:error] = "No Artful.ly user found with email address #{params[:user_email]}. Tell them to sign up!" and return if user.nil?
      block.call(user)
    end

end