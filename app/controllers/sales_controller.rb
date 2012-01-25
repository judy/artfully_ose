class SalesController < ApplicationController
  before_filter :find_event, :find_show, :find_people, :find_dummy
  before_filter :create_door_list, :only => ['show', 'new']

  def show
    redirect_to new_event_show_sales_path(@event, @show)
  end

  def new
    @person = Person.new
    @sale = Sale.new(@show, @show.chart.sections)
    setup_defaults
  end

  def create
    @sale = Sale.new(@show, @show.chart.sections, params[:quantities])
    if checking_out?
      if @sale.sell(payment)
        @sale.message = "Sold #{self.class.helpers.pluralize(@sale.tickets.length, 'ticket')}.  Order total was #{self.class.helpers.number_as_cents @sale.cart.total}"
      else
        @sale.message =  "#{@sale.errors.full_messages.to_sentence.capitalize}."
      end
    end
    render :json => @sale.as_json.merge(:total => @sale.cart.total).merge(:door_list_rows => door_list_rows), :status => 200
  end

  def checking_out?
    !params[:commit].blank?
  end
  
  def door_list_rows
    door_list_rows = []
    @sale.tickets.each_with_index do |ticket, i|
      if ticket.sold? || ticket.comped?
        door_list_rows[i] = {}
        door_list_rows[i]['buyer'] = (@sale.buyer.first_name || "") + " " + (@sale.buyer.last_name || "")
        door_list_rows[i]['email'] = @sale.buyer.email
        door_list_rows[i]['section'] = ticket.section.name
        door_list_rows[i]['price'] = ticket.section.price
      end
    end
    door_list_rows
  end

  private
    def setup_defaults
      params[:anonymous]   = true
      params[:cash]        = true
      params[:credit_card] = {}
    end

    def find_event
      @event = Event.find(params[:event_id])
    end

    def find_show
      @show = Show.find(params[:show_id])
      authorize! :view, @show
    end

    def find_people
      if params[:terms].present?
        @people = Person.search_index(params[:terms].dup, current_user.current_organization)
      else
        @people = []
      end
    end

    def create_door_list
      @door_list = DoorList.new(@show)
    end

    def find_dummy
      @dummy = Person.dummy_for(current_user.current_organization)
    end

    def person
      Person.find(params[:person_id])
    end

    def payment
      case params[:payment_method]
      when 'cash'
        CashPayment.new(person.to_customer)
      when 'comp'
        CompPayment.new(current_user, person)
      when 'credit_card_swipe'
        card = AthenaCreditCard.from_swipe(params[:credit_card][:card_number])
        CreditCardPayment.for_card_and_customer(card, person.to_customer)
      when 'credit_card_manual'
        card = AthenaCreditCard.new(params[:credit_card])
        CreditCardPayment.for_card_and_customer(card, person.to_customer)
      end
    end
  
    def has_card_info?
      params[:credit_card].present? and params[:credit_card][:card_number].present?
    end

end