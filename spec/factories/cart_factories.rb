Factory.define :cart do |o|
end

Factory.define :cart_with_items, :parent => :cart do |o|
  o.after_create do |order|
    order.tickets << 3.times.collect { Factory(:ticket) }
    order.donations << Factory(:donation)
  end
end