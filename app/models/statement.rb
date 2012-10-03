class Statement  
  attr_accessor :datetime, 
                :tickets_sold, 
                :tickets_comped, 
                :potential_revenue, 
                :gross_revenue, 
                :processing, 
                :net_revenue,
                :due,
                :settled,
                :payment_method_rows
  
  def self.for_show(show, organization)
    if show.nil? || organization.nil?
      return new
    end
    
    new.tap do |statement|
      statement.datetime          = show.datetime_local_to_event
      statement.tickets_sold      = show.tickets.select{|t| t.sold?}.size
      statement.tickets_comped    = show.tickets.select{|t| t.comped?}.size
      statement.potential_revenue = show.tickets.inject(0) { |total_price, ticket| total_price += ticket.price }
      statement.gross_revenue     = show.items.inject(0) { |gross, item| gross += item.price }
      statement.net_revenue       = show.items.inject(0) { |net, item| net += item.net }
      statement.processing        = statement.gross_revenue - statement.net_revenue
      
      #
      # This is the business rule definition of money due to a producer.  
      # It's important not to use show.settlebles here because *this is the check that show.settlables works*. 
      # If show.settleables is broken, this will show that
      #
      
      statement.due = 0
      show.items.each do |item| 
        statement.due += item.net if item.order.credit? 
      end
      statement.settled           = show.settlements.successful.inject(0) { |settled, settlement| settled += settlement.net }
      payment_method_hash         = show.items.group_by { |item| item.order.payment_method }
      
      statement.payment_method_rows         = {}
      
      # Initialize with the three common payment types
      statement.payment_method_rows[::CreditCardPayment.payment_method] = PaymentTypeRow.new
      statement.payment_method_rows[::CashPayment.payment_method] = PaymentTypeRow.new
      statement.payment_method_rows[::CompPayment.payment_method] = PaymentTypeRow.new
      
      
      payment_method_hash.each do |payment_method, items|
        row = statement.payment_method_rows[payment_method] || PaymentTypeRow.new
        items.each {|item| row << item}
        statement.payment_method_rows[payment_method] = row
      end
    end
  end
  
  class PaymentTypeRow
    attr_accessor :payment_method,
                  :tickets_sold, 
                  :gross,
                  :processing,
                  :net
    
    def initialize
      self.tickets_sold = 0
      self.gross = 0
      self.processing = 0
      self.net = 0
    end
    
    def<<(item)
      self.tickets_sold = self.tickets_sold + 1
      self.gross        = self.gross + item.price
      self.processing   = self.processing + (item.realized_price - item.net)
      self.net          = self.net + item.net
    end
  end
end