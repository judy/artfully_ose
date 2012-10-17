class EventsController < ArtfullyOseController
  respond_to :html, :json

  before_filter :find_event, :only => [ :show, :edit, :update, :destroy, :widget, :image, :storefront_link, :prices, :messages, :resell ]
  before_filter :upcoming_shows, :only => :show

  def create
    @event = Event.new(params[:event])
    @templates = current_organization.charts.template
    @event.organization_id = current_user.current_organization.id
    @event.is_free = !(current_user.current_organization.can? :access, :paid_ticketing)
    @event.venue.organization_id = current_user.current_organization.id
    @event.venue.time_zone = current_user.current_organization.time_zone
    if @event.contact_email.blank?
      @event.contact_email = current_user.email
      flash[:notice] = "Event's contact email address for patrons was set to <b>your</b> email address. Please set your organization's email address <a href=\"#{edit_organization_path(current_organization)}\">here.</a>".html_safe
    end

    if @event.save
      redirect_to edit_event_url(@event)
    else
      render :new
    end
  end

  def index
    authorize! :view, Event
    @events = current_organization.events.includes(:shows, :venue).order('updated_at DESC')
  end

  def show
    authorize! :view, @event
    @shows = @event.shows.paginate(:page => params[:page], :per_page => 25)

    respond_to do |format|
      format.json do
        render :json => @event.as_full_calendar_json
      end

      format.html do
        render :show
      end
    end

  end

  def new
    @event = current_organization.events.build(:producer => current_organization.name)
    @event.venue = Venue.new
    authorize! :new, @event
    @templates = current_organization.charts.template
  end

  def edit
    authorize! :edit, @event
  end
  
  def image
    authorize! :edit, @event
  end

  def assign
    @event = Event.find(params[:event_id])
    @chart = Chart.find(params[:chart][:id])
    @event.assign_chart(@chart)

    flash[:error] = @event.errors.full_messages.to_sentence unless @event.errors.empty?

    redirect_to event_url(@event)
  end

  def update    
    authorize! :edit, @event

    @event.update_attributes(params[:event])
    if @event.save
      if user_requesting_next_step?
        if user_just_uploaded_an_image?
          redirect_to messages_event_path(@event)
        elsif user_set_special_instructions?
          redirect_to event_shows_path(@event)
        else
          redirect_to edit_event_venue_path(@event)
        end
      else
        flash[:notice] = "Your event has been updated."
        redirect_to event_url(@event)
      end
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @event
    @event.destroy
    flash[:notice] = "Your event has been deleted"
    redirect_to events_url
  end

  def widget
  end

  def storefront_link
  end
  
  def prices
  end
  
  def messages
  end

  def resell
    @organization = current_user.current_organization

    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @ticket_offer.reseller_profile = ResellerProfile.find_by_id(params[:reseller_profile_id])

    # Get the master list of resellers.
    @reseller_profiles = ResellerProfile.joins(:organization).order("organizations.name").all

    # Grab the list of Events.
    @events = @organization.events.includes(:shows)

    # Build an EventID -> Shows hash.
    @shows = @events.to_h { |event| [ event.id, event.shows.unplayed.all ] }

    # Build a ShowID -> Sections hash.
    @sections = @shows.values.flatten.to_h { |show| [ show.id, show.tickets.includes(:section).map(&:section).uniq ] }

    # Build a list of ticket counts per section.
    @counts = {}
    @shows.map do |event_id, shows|
      shows.each do |show|
        show.
          tickets.
          resellable.
          select("section_id, COUNT(*) AS count").
          group("section_id").
          each do |t|
            @counts[show.id] ||= {}
            @counts[show.id][t.section_id] = t.count
          end
      end
    end
  end

  private
    def find_event
      @event = Event.find(params[:id])
    end

    def user_set_special_instructions?
      !params[:event][:special_instructions_caption].nil?
    end

    def find_charts
      ids = params[:charts] || []
      ids.collect { |id| Chart.find(id) }
    end

    def upcoming_shows
      @upcoming = @event.upcoming_shows
    end
end
