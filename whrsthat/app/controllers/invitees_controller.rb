class InviteesController < ApplicationController
  before_action :set_invitee, only: [:show, :edit, :update, :destroy]
  # Allow Twilio to POST to this endpoint
  protect_from_forgery with: :null_session
 


  def text
    # The number the text came from 
    from_number = params['From']
    body = params['Body']

    invite = EventUser.find_by(:number => from_number, accepted: nil)

    if invite != nil && invite.user != nil && invite.accepted == nil
      if body.downcase.include?('y')
        invite.accepted = true
        invite.save()
        twilio.messages.create(
          from: ENV['TWILIO_FROM_NUMBER'],
          to: invite.number,
          body: "Thank you for attening #{invite.event.title}. See details about this event at #{invite.event.url}"
        )
      elsif body.downcase.include?('n')
        invite.accepted = false
        invite.save()
      else
        # If the user didn't send Y(es) or N(o)

      end
    end
    render :nothing => true, :status => 204, :content_type => 'text/html'
  end

  def respond 
    @invite = EventUser.find(params['id'])

    @invite.accepted = (params['accepted'] === 'true')
    @invite.save

    render :nothing => true, :status => 204, :content_type => 'text/html'
  end

  # GET /invitees
  # GET /invitees.json
  def index
    @invitees = Invitee.all
  end

  # GET /invitees/1
  # GET /invitees/1.json
  def show

    @invite = EventUser.find(params['id'])
    if @invite.accepted != nil
      redirect_to("/events/#{@invite.event.id}")
    end
  end

  # GET /invitees/new
  def new
    @invitee = Invitee.new
  end

  # GET /invitees/1/edit
  def edit

  end



  # POST /invitees
  # POST /invitees.json
  def create
    @invitee = Invitee.new(invitee_params)

    respond_to do |format|
      if @invitee.save
        format.html { redirect_to @invitee, notice: 'Invitee was successfully created.' }
        format.json { render :show, status: :created, location: @invitee }
      else
        format.html { render :new }
        format.json { render json: @invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitees/1
  # PATCH/PUT /invitees/1.json
  def update
    respond_to do |format|
      if @invitee.update(invitee_params)
        format.html { redirect_to @invitee, notice: 'Invitee was successfully updated.' }
        format.json { render :show, status: :ok, location: @invitee }
      else
        format.html { render :edit }
        format.json { render json: @invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitees/1
  # DELETE /invitees/1.json
  def destroy
    @invitee.destroy
    respond_to do |format|
      format.html { redirect_to invitees_url, notice: 'Invitee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitee
      # binding.pry
      @invitee = EventUser.find(params['id'])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitee_params
      params.require(:invitee).permit(:attending)
    end
end
