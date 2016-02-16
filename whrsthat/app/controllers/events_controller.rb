require 'pry'
require 'exifr' 
require 'gmaps4rails'

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session

  # GET /events
  # GET /events.json
  def index
    if current_user == nil
      redierct_to('/login')
    end
    @events = Event.where({ user_id: current_user.id })
    @invitations = EventUser.where({ number: current_user.phone }).map { |invite| invite.event }
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params['id'])
    # @event = Event.find(params['id'])
    @invites = EventUser.where(event_id: params['id'].to_i)
    @accepted_invites = @invites.where.not(accepted: false)
    @new_invite = EventUser.new
    @event_place_id = @event.place_id
    @accepted_invites.each { |invite|
      @user = invite.user
      if @user.longitude && @user.latitude
        google_server_key = ENV['GOOGLE_SERVER_KEY']
        google_uri = URI("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{@user.latitude},#{@user.longitude}&key=#{google_server_key}")
        result = Net::HTTP.get(google_uri)
        google_user_location_data = JSON.parse(result)
        @invite_place_id = google_user_location_data.flatten[1][0]["place_id"]
        invite.update_attributes(:place_id => @invite_place_id)
        invite_eta = URI("https://maps.googleapis.com/maps/api/directions/json?origin=place_id:#{@invite_place_id}&destination=place_id:#{@event_place_id}&mode=transit&transit_mode=subway&key=#{google_server_key}")
        eta_result  = Net::HTTP.get(invite_eta)
        eta_parsed = JSON.parse(eta_result)
        arrival_time = eta_parsed.flatten[3][0]["legs"][0]["arrival_time"]["text"]
        invite.update_attributes(:eta => arrival_time)
      end
    }

    markers = [@event, @event.user].concat(@accepted_invites)
     @hash = Gmaps4rails.build_markers(markers) do |obj, marker|
      if obj.class.name === 'Event'
        event = obj
        marker.lat event.latitude
        marker.lng event.longitude
        marker.picture({
          url: "#{view_context.image_path('/assets/precious.png')}",
          
          width: "44",
          height: "90"
        })
        # marker.infowindow event.title
        marker.title event.title

        current_user.local_ip = request.remote_ip
        current_user.save()
      elsif obj.class.name === 'EventUser'
        invite = obj
        @user = invite.user
        @invite = invite
        user_photo = @user.prof_img_url
        user_event_eta = @invite.eta
        user_full_name = @user.name
        marker.lat @user.latitude
        marker.lng @user.longitude
        marker.picture({
          url: "#{view_context.image_path('/assets/precious.png')}",
          width: "44",
          height: "90"
        })

        marker.infowindow user_full_name

      elsif 
        @user = obj
        user_photo = @user.prof_img_url
        # user_event_eta = @invite.eta
        user_full_name = @user.name
        marker.lat @user.latitude
        marker.lng @user.longitude
        marker.picture({
          url: "#{view_context.image_path('/assets/precious.png')}",
          width: "44",
          height: "90"
        })

        marker.infowindow user_full_name        
      end
    end

  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    ev_params = event_params.clone

    ev_params[:user_id] = current_user.id
    ev_params[:longitude] = ev_params[:longitude].to_f
    ev_params[:latitude] = ev_params[:latitude].to_f
    @event = Event.new(ev_params, params[:event][:photo])

    respond_to do |format|
      # tempfile = params[:event][:photo]
      
      if @event.save

        # file = File.open('./public/IMG_3503.JPG')

        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }

      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    render :nothing => true, :status => 200, :content_type => 'text/plain'
  end

  def invite 
    in_params = invite_params.clone
    @event = Event.find(params['id'])
    in_params['event_id'] = @event.id
    @new_invite = EventUser.new(in_params)
    @new_invite.save()
    @invites = EventUser.where(event_id: params['id'].to_i)
    render :show
  end

  def invite_destroy 
    invite = EventUser.find(params['invite_id'])
    invite.destroy

    render :nothing => true, :status => 200, :content_type => 'text/plain'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event    
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :caption, :time_at, :event_img_url, :longitude, :latitude, :event_address, :photo, :place_id)
    end

    def invite_params
      params.require(:event_user).permit(:number, :event_id)
    end
end
