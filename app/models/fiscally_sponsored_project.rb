class FiscallySponsoredProject < ActiveRecord::Base
  belongs_to :organization

  def refresh
    begin
      project = FA::Project.find_active_by_member_id(fa_member_id)
      update_attributes(self.class.attributes_from(project))
    rescue ActiveResource::ResourceNotFound
      logger.debug("No active FAFS project found for member id #{fa_member_id}")
      update_attributes(self.class.clear)
    end
  end

  def active?
    status == "Active"
  end

  def inactive?
    !active?
  end

  private
    def self.attributes_from(project)
      { :fs_project_id => project.id,
        :fa_member_id  => project.member_id,
        :name          => project.name,
        :category      => project.category,
        :profile       => project.profile,
        :website       => project.website,
        :applied_on    => DateTime.parse(project.applied_on),
        :status        => project.status }
    end
    
    #Sucks to repeat this hash, but coudln't think of another way to do
    #it without blowing up the thing that is going on.
    def self.clear
      { :fs_project_id => nil,
        :fa_member_id  => nil,
        :name          => nil,
        :category      => nil,
        :profile       => nil,
        :website       => nil,
        :applied_on    => nil,
        :status        => nil }
    end
end