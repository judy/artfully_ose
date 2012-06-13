Factory.sequence :datetime do |n|
  DateTime.now + 7.days + n.minutes
end

Factory.define(:show) do |s|
  s.datetime { Factory.next :datetime }
  s.association :organization
  s.association :event
  s.association :chart, :factory => :assigned_chart
end

Factory.define(:show_with_tickets, :parent => :show) do |s|
  s.after_create do |show|
    # tickets.each do |t|
    # end
    show.build!
    show.publish!
  end
end

Factory.define(:settleable_show, :parent => :show_with_tickets) do |s|
  s.association :organization, :factory => :organization_with_bank_account
  s.after_create do |show|
    show.tickets.each do |ticket|
      ticket.sell_to(Factory(:person))
      Item.for(ticket).save
    end
  end
end

Factory.define(:expired_show, :parent => :show) do |s|
  s.datetime { DateTime.now - 1.day}
end
