class Store::OrdersController < Store::StoreController
  layout "cart"
  skip_before_filter :verify_authenticity_token

  def show
    @donations = current_cart.generate_donations
  end

  def create
    handle_order(params)
    redirect_to store_order_url
  end

  def update
    handle_order(params)
    redirect_to store_order_url
  end

  def destroy
    current_cart.destroy
    redirect_to store_order_url
  end

  private
    def handle_order(params)
      handle_tickets(params[:tickets]) if params.has_key? :tickets
      handle_donation(params[:donation]) if params.has_key? :donation

      unless current_cart.save
        flash[:error] = current_cart.errors
      end
    end

    def handle_tickets(ids)
      current_cart << Ticket.find(ids)
    end

    def handle_donation(data)
      donation = Donation.new

      donation.amount = data[:amount]
      donation.organization = Organization.find(data.delete(:organization_id))

      current_cart.donations << donation
    end
end
