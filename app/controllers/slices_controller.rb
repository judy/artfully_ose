class SlicesController < ArtfullyOseController
  before_filter :load_statement

  def index
  end

  def data
    data = []
    # @statement.payment_method_rows.values.each do |row|
    #   data << Slice.new(row.payment_method, ["#AA0000","#00AA00","#000099"].sample, row.tickets) unless row.tickets == 0
    # end

    data = Slicer.slice(nil, nil, [["A","B"], ["1", "2", "3"], ["XX", "YY", "ZZ"]], 0)

    respond_to do |format|
      #format.json { render :partial => "data.json" }
      format.json { render :json => Array.wrap(data) }
    end
  end

  def load_statement
    @show = Show.includes(:event => :venue, :items => :order).find(params[:statement_id])
    authorize! :view, @show
    @event = @show.event
    @shows = @event.shows.includes(:event => :venue)
    @statement = Statement.for_show(@show, @show.imported?)
  end
end