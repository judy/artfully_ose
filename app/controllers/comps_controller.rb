class CompsController < ApplicationController
  def new
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    @comp = Comp.new(@performance, @selected_tickets, recipient)
    @recipients = recipients || []
    if @comp.has_recipient?
      render :new
    else
      flash[:error] = "No people were found when searching for \"#{params[:terms]}\"." if !params[:terms].blank? and @recipients.empty?
      render :find_person
    end
  end

  def create
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    @comp = Comp.new(@performance, @selected_tickets, recipient)
    @comp.reason = params[:reason_for_comp]

    with_confirmation_comp do
      @comp.submit(current_user)
      if @comp.uncomped_count > 0
        flash[:alert] = "Comped #{to_plural(@comp.comped_count, 'ticket')}. #{to_plural(@comp.uncomped_count, 'ticket')} could not be comped."
      else
        flash[:notice] = "Comped #{to_plural(@comp.comped_count, 'ticket')}."
      end

      redirect_to event_performance_url(@performance.event, @performance)
    end
  end

  def with_confirmation_comp
    if params[:confirmed].blank?
      @comp.reason = params[:comp_reason]
      flash[:info] = "Please confirm your changes before we save them."
      render 'comp_confirm' and return
    else
      yield
    end
  end

  private

  def recipients
    AthenaPerson.search_index(params[:terms].dup, current_user.current_organization) unless params[:terms].blank?
  end

  def recipient
    AthenaPerson.find(params[:person_id]) if params[:person_id]
  end
end