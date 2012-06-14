require_or_load 'ach/exceptions'

class ResellerSettlement < Settlement
  include Settlement::RangeFinding
  include AdminTimeZone

  def self.submit(organization_id, items, bank_account, show_id = nil)
    items = Array.wrap(items)
    response = process(items, bank_account)

    for_items!(items) do |settlement|
      settlement.ach_response_code = response[:ach_response_code]
      settlement.transaction_id    = response[:transaction_id]
      settlement.fail_message      = response[:fail_message]
      settlement.success           = response[:success]
      settlement.organization_id   = organization_id
      settlement.show_id           = show_id
    end
  end
  
  def self.range_for(now)
    range_for_previous_month(now)
  end

  private

  def self.process(items, bank_account)
    if items.empty? # This is considered a success.  No items, no money to transfer, we're done
      succeed_with(nil, :message => "There are no items for this settlement")
    elsif bank_account.nil?
      fail_with(:message => "This organization has no bank account")
    else
      begin
        transaction_id = send_request(items, bank_account, "Artful.ly Settlement #{Date.today}")
        succeed_with(transaction_id, :code => ACH::Request::SUCCESS)
      rescue ACH::ClientError => e
        fail_with(:message => "#{e.backtrace.inspect}", :code => e.to_s)
      rescue Exception => e
        fail_with(:message => "#{e.to_s} #{e.backtrace.inspect}", :code => e.to_s)
      end
    end
  end

  def self.for_items(items, &block)
    new.tap do |settlement|
      settlement.items          = items
      settlement.gross          = items.sum(&:price)
      settlement.realized_gross = items.sum(&:realized_price)
      settlement.net            = items.sum { |i| i.reseller_net.to_i }
      settlement.items_count    = items.size

      block.call(settlement) if block.present?
      settlement
    end
  end

  def self.for_items!(items, &block)
    settlement = for_items(items, &block)
    settlement.save!
    settlement
  end

  def self.send_request(items, bank_account, memo)
    net = items.sum { |i| i.reseller_net.to_i }
    request = ACH::Request.for(net, bank_account, memo)
    request.submit
  end

  def self.fail_with(options = {})
    {
      :success           => false,
      :ach_response_code => options[:code],
      :fail_message      => options[:message]
    }
  end

  def self.succeed_with(transaction_id, options = {})
    {
      :success           => true,
      :ach_response_code => options[:code],
      :fail_message      => options[:message],
      :transaction_id    => transaction_id
    }
  end
end
