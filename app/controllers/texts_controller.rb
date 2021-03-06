class TextsController < ApplicationController
  before_filter :authenticate_user!, :only => [:my, :new, :edit, :create, :update, :destroy]
  protect_from_forgery
  before_filter :menu

  def menu
    @mainmenu = Menu.all
  end

  # GET /texts
  # GET /texts.json
  def index
    if user_signed_in?
      @texts = Text.all(:joins => :owners, :order => "created_at DESC", :conditions => ["owners.user_id = #{current_user.id} OR texts.publish = true" ])
    else
      @texts = Text.all(:joins  => :owners, :order => "created_at DESC", :conditions => ["texts.publish = true"])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @all }
    end
  end

  # GET /texts/my
  # GET /texts/my.json
  def my
    if user_signed_in?
      @texts = Text.all(:joins => :owners, :order => "created_at DESC", :conditions => ["owners.user_id = #{current_user.id}" ])
    else
      @texts = Text.all(:joins  => :owners, :order => "created_at DESC", :conditions => ["texts.publish = true"])
    end

    respond_to do |format|
      format.html # my.html.erb
      format.json { render :json => @all }
    end
  end

  # GET /texts/1
  # GET /texts/1.json
  def show
    @text = Text.find(params[:id].downcase)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @text }
    end
  end

  # GET /texts/new
  # GET /texts/new.json
  def new
    @licenses = License.all
    @text = Text.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @text }
    end
  end

  # GET /texts/1/edit
  def edit
    @licenses = License.all

    @text = Text.find(params[:id].downcase)
  end

  # POST /texts
  # POST /texts.json
  def create
    @licenses = License.all
    @text = Text.create(params[:text])

    respond_to do |format|
      if @text.save
        format.html { redirect_to texts_url, :notice => 'Successfully created' }
        format.json { render :json => @text, :status => :created, :location => @text }
      else
        format.html { render :action => "new" }
        format.json { render :json => @text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /texts/1
  # PUT /texts/1.json
  def update
    @licenses = License.all
    @text = Text.find(params[:id].downcase)

    @text.owners.each do |owner|
      if current_user.id != owner.user_id
          redirect_to texts_url, :alert => I18n.t('Permission Denied')
          return false
      end
    end

    respond_to do |format|
      if @text.update_attributes(params[:text])
        format.html { redirect_to texts_url, :notice => 'Successfully updated' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @text.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /texts/1
  # DELETE /texts/1.json
  def destroy
    @text = Text.find(params[:id].downcase)

    @text.owners.each do |owner|
      if current_user.id != owner.user_id
          redirect_to texts_url, :alert => I18n.t('Permission Denied')
          return false
      end
    end

    @text.destroy

    respond_to do |format|
      format.html { redirect_to texts_url, :notice => 'Successfully deleted' }

      format.json { head :no_content }
    end
  end

  def rss
    @texts = Text.find(:all, :order => "id DESC", :limit => 10)

    @title = Settings.title
    @description = Settings.description

    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def search
    @texts = Text.search do
      keywords params[:query]
      order_by :created_at, :desc
    end.results

    respond_to do |format|
      format.html { render :action => "index" }
      format.xml  { render :xml => @texts }
      format.json { render :json => @texts }
    end
  end

  def tagged
    if params[:tag].present?
      @texts = Text.tagged_with(params[:tag])
    else
      @texts = Text.all
    end
  end

end
