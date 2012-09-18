class Import < ActiveRecord::Base
  
  include Importing::Status
  include Importing::Processing

  has_many :import_errors, :dependent => :delete_all
  has_many :import_rows, :dependent => :delete_all
  has_many :people, :dependent => :destroy

  serialize :import_headers
  
  set_watch_for :created_at, :local_to => :organization

  def headers
    self.import_headers
  end

  def rows
    self.import_rows.map(&:content)
  end

  def perform
    if status == "caching"
      self.cache_data
    elsif status == "approved"
      self.import
    end
  end

  def import
    self.importing!

    self.people.destroy_all
    self.import_errors.delete_all

    rows.each do |row|
      ip = ImportPerson.new(headers, row)
      person = attach_person(ip)
      if !person.save
        self.import_errors.create! :row_data => row, :error_message => person.errors.full_messages.join(", ")
        self.reload
        self.failed!
      end
    end

    if failed?
      self.people.destroy_all
    else
      self.imported!
    end
  end

  def cache_data
    @csv_data = nil

    raise "Cannot load CSV data" unless csv_data.present?

    self.import_headers = nil
    self.import_rows.delete_all
    self.import_errors.delete_all

    csv_data.gsub!(/\\"(?!,)/, '""') # Fix improperly escaped quotes.

    CSV.parse(csv_data, :headers => false) do |row|
      if self.import_headers.nil?
        self.import_headers = row.to_a
        self.save!
      else
        self.import_rows.create!(:content => row.to_a)
      end
    end

    self.pending!
  rescue CSV::MalformedCSVError => e
    error_message = "There was an error while parsing the CSV document: #{e.message}"
    self.import_errors.create!(:error_message => error_message)
    self.failed!
  rescue Exception => e
    self.import_errors.create!(:error_message => e.message)
    self.failed!
  end

  def attach_person(import_person)
    ip = import_person

    person = self.people.build \
      :email           => ip.email,
      :first_name      => ip.first,
      :last_name       => ip.last,
      :company_name    => ip.company,
      :website         => ip.website,
      :twitter_handle  => ip.twitter_username,
      :facebook_url    => ip.facebook_page,
      :linked_in_url   => ip.linkedin_page,
      :organization_id => user.current_organization.id,
      :person_type     => ip.person_type

    person.address = Address.new \
      :address1  => ip.address1,
      :address2  => ip.address2,
      :city      => ip.city,
      :state     => ip.state,
      :zip       => ip.zip,
      :country   => ip.country

    person.tag_list = ip.tags_list.join(", ")

    1.upto(3) do |n|
      kind = ip.send("phone#{n}_type")
      number = ip.send("phone#{n}_number")
      if kind.present? && number.present?
        person.phones << Phone.new(kind: kind, number: number)
      end
    end

    person
  end

end
