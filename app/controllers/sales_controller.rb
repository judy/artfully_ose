class SalesController < ApplicationController
  before_filter :find_event, :find_show, :create_door_list, :find_dummy

  def show
    redirect_to new_event_show_sales_path(@event, @show)
  end

  def new
    @sale = Sale.new(@show, @show.chart.sections)
  end

  def create
    @sale = Sale.new(@show, @show.chart.sections, params[:quantities])

    if @sale.sell(payment)
      redirect_to new_event_show_sales_path(@event, @show), :notice => 'Items successfully purchased.'
    else
      flash[:error] = "An error occured while trying to finish the order."
      render :new
    end
  end

  private

  def find_event
    @event = AthenaEvent.find(params[:event_id])
  end

  def find_show
    @show = AthenaPerformance.find(params[:show_id])
    authorize! :view, @show
  end

  def create_door_list
    @door_list = DoorList.new(@show)
  end

  def find_dummy
    @dummy = AthenaPerson.dummy_for(current_user.current_organization)
  end

  def person
    AthenaPerson.find(params[:person_id])
  end

  def payment
    if has_card_info?
      card = AthenaCreditCard.new(params[:credit_card])
      CreditCardPayment.for_card_and_customer(card, person.to_customer)
    else
      CashPayment.new(person.to_customer)
    end
  end

  def has_card_info?
    params[:credit_card].present? and params[:credit_card][:card_number].present?
  end

end