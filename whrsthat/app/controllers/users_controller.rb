require 'open-uri'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    reset_session
    if request.referer
      session[:referer] = request.referer
    end
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def set_session(user)
    session[:user_name] = user.email
    session[:user] = user.id
    @user = current_user
    @name = session[:user_name]
  end

  # POST /users
  # POST /users.json
  def create
    tmp_obj = JSON.parse(JSON.generate(user_params))
    tmp_obj['password'] = params['password']
    @user = User.new( tmp_obj )
    if @user.save
      set_session @user
        if session[:referer] 
          redirect_to session[:referer]
        else
          redirect_to '/events'
        end
    else
      render :new 
    end
  end

# NoMethodError Users#login for user.each

  def google_create

    # code = params[:code]
    # our_url = ENV['EXTERNAL_URL']

    # form = {
    #     :code => code,
    #     :client_id => ENV['GOOGLE_OAUTH_CLIENT_ID'],
    #     :client_secret => ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
    #     :grant_type => 'authorization_code',
    #     :redirect_uri => "#{our_url}/auth/google_oauth2/callback"
    #   }

    # uri = URI.parse("https://www.googleapis.com")
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # request = Net::HTTP::Post.new("/oauth2/v4/token")
    # request.set_form_data form
    # response = http.request(request)

    # access_token = JSON.parse(response.body)["access_token"]

    google_user = request.env['omniauth.auth'][:info]
    
    user = User.create({
      fname:         google_user["first_name"],
      lname_initial: google_user["last_name"],
      email:         google_user["email"],
      prof_img_url:  google_user["image"]
    })


    if user.save
      set_session user
      redirect_to('/events')
    else
      user = User.find_by(:email => google_user["email"])
      if user
        set_session user
        redirect_to('/events')
      else
        redirect_to('/login')
      end
    end

  end

  def geo
    if current_user != nil
      latitude = params["latitude"].to_f
      longitude = params["longitude"].to_f
      current_user.latitude = latitude
      current_user.longitude = longitude
      current_user.save
    end

    render :nothing => true, :status => 204
  end


  def login
    if request.method == 'POST'
      user = User.find_by(email: params['email'])
        # checks the db for a user that matches the name submitted.

      if user && user.authenticate(params['password'])
        #if user exists and password is legit then.....
        set_session user

        if session[:referer] 
          redirect_to session[:referer]
        else
          redirect_to '/events'
        end
      else
        @error = true
        render 'users/login'
      end
    else
      if current_user == nil
        @force_redirect = params[:force].present?
        if request.referer
          session[:referer] = request.referer
        end
        render 'users/login'
      else
        redirect_to('/events')
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    current_user.phone = params['phone']
    current_user.save()

    render :nothing => true, :status => 204
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def logout
    reset_session
    @user = nil
    redirect_to('/login')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:phone, :fname, :lname_initial, :email, :password_digest, :prof_img_url)
    end
end
