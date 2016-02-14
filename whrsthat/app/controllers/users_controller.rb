require 'open-uri'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
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
    respond_to do |format|
      if @user.save
        set_session @user
        format.html { render 'events/index', notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

# NoMethodError Users#login for user.each

  def google_create
    code = params[:code]
    our_url = "https://d076d188.ngrok.io"

    form = {
        :code => code,
        :client_id => ENV['GOOGLE_OAUTH_CLIENT_ID'],
        :client_secret => ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
        :grant_type => 'authorization_code',
        :redirect_uri => "#{our_url}/auth/google_oauth2/callback"
      }

    uri = URI.parse("https://www.googleapis.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new("/oauth2/v4/token")
    request.set_form_data form
    response = http.request(request)

    access_token = JSON.parse(response.body)["access_token"]

    google_user = JSON.parse(open("https://www.googleapis.com/plus/v1/people/me?access_token=#{access_token}").read)

    user = User.create({
      fname:         google_user["name"]["givenName"],
      lname_initial: google_user["name"]["familyName"],
      email:         google_user["emails"][0]["value"],
      prof_img_url:  google_user["image"]["url"]
    })

    if user.save
      redirect_to('/events')
    else
      redirect_to('/login')

    end

  end

  def login
    if params['email'] && params['password']
      user = User.find_by(email: params['email'])
        # checks the db for a user that matches the name submitted.

      if user && user.authenticate(params['password'])
        #if user exists and password is legit then.....
        set_session user

        render 'events/index'

      else
        @error = true
        render 'main/home'
      end
    else
      render 'users/login'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
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
