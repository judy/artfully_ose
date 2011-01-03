class TicketsController < ApplicationController
  def index
    @tickets = AthenaTicket.search(params)
    respond_to do |format|
      format.html
      format.widget
      format.jsonp  { render_jsonp (@tickets.to_json) }
    end
  end

  def show
    @ticket = AthenaTicket.find(params[:id])
  end
end
