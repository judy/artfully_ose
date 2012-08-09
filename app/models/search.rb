class Search < ActiveRecord::Base
  attr_accessible :zip, :state, :event_id, :tagging,
                  :min_lifetime_value, :max_lifetime_value,
                  :min_donations_amount, :max_donations_amount,
                  :min_donations_date, :max_donations_date
  belongs_to :organization
  belongs_to :event
  validates_presence_of :organization_id

  def length
    people.length
  end

  def people
    @people ||= find_people
  end

  def description
    conditions = []
    conditions << "are tagged with #{tagging}" if tagging.present?
    conditions << "bought tickets for #{event.name}" if event_id.present?
    if zip.present? || state.present?
      locations = []
      locations << state if state.present?
      locations << "the zipcode of #{zip}" if zip.present?
      conditions << "are located within #{locations.to_sentence}"
    end
    if min_lifetime_value.present? && max_lifetime_value.present?
      conditions << "have a lifetime value between $#{min_lifetime_value} and $#{max_lifetime_value}"
    elsif min_lifetime_value.present?
      conditions << "have a minimum lifetime value of $#{min_lifetime_value}"
    elsif max_lifetime_value.present?
      conditions << "have a maximum lifetime value of $#{max_lifetime_value}"
    end

    unless [min_donations_amount, max_donations_amount, min_donations_date, max_donations_date].all?(&:blank?)
      if min_donations_amount.present? && max_donations_amount.present?
        string = "made between $#{min_donations_amount} and $#{max_donations_amount} in donations"
      elsif min_donations_amount.present?
        string = "made a total minimum of $#{min_donations_amount} in donations"
      elsif max_donations_amount.present?
        string = "made no more than $#{max_donations_amount} in total donations"
      else
        string = "made any donations"
      end

      if min_donations_date.present? && max_donations_date.present?
        string << " from #{min_donations_date.strftime('%D')} to #{max_donations_date.strftime('%D')}"
      elsif min_donations_date.present?
        string << " after #{min_donations_date.strftime('%D')}"
      elsif max_donations_date.present?
        string << " before #{max_donations_date.strftime('%D')}"
      else
        string << " overall"
      end
      conditions << string
    end

    if conditions.blank?
      return "All people."
    else
      return "People that #{conditions.to_sentence}."
    end
  end

  private

  def find_people
    column_names = Person.column_names.collect {|cn| "people.#{cn}" }

    people = Person.where(:organization_id => organization_id)
    people = people.order('lower(last_name) ASC')
    people = people.tagged_with(tagging) unless tagging.blank?
    people = people.joins(:address) unless zip.blank? && state.blank?
    people = people.joins(:tickets => {:show => :event}).where("events.id" => event_id) unless event_id.blank?
    people = people.where("addresses.zip" => zip) unless zip.blank?
    people = people.where("addresses.state" => state) unless state.blank?
    people = people.where("people.lifetime_value >= ?", min_lifetime_value * 100.0) unless min_lifetime_value.blank?
    people = people.where("people.lifetime_value <= ?", max_lifetime_value * 100.0) unless max_lifetime_value.blank?
    unless [min_donations_amount, max_donations_amount, min_donations_date, max_donations_date].all?(&:blank?)
      column_names << "SUM(items.price + items.nongift_amount) AS total_donations"
      people = people.joins(:orders => :items)
      people = people.where("orders.created_at >= ?", min_donations_date) unless min_donations_date.blank?
      people = people.where("orders.created_at <= ?", max_donations_date + 1.day) unless max_donations_date.blank?
      people = people.where("items.product_type = 'Donation'")
      people = people.group("people.id")
      if min_donations_amount.blank?
        people = people.having("total_donations >= 1")
      else
        people = people.having("total_donations >= ?", min_donations_amount * 100.0)
      end
      people = people.having("total_donations <= ?", max_donations_amount * 100.0) unless max_donations_amount.blank?
    end
    people.select(column_names).uniq
  end
end
