require 'rubygems'
require 'sinatra'
require 'active_record'
require 'builder'
require 'yaml'

# Load models
Dir.glob(File.join(File.dirname(__FILE__), './db/models/*.rb')).each {|f| require f }

enable :sessions
enable :logging

# logFile = File.open('log/database.log','a+')
# @logger = Logger.new(logFile)
# @logger.level = Logger::INFO

@environment =  ENV['RACK_ENV'] || development? ? 'development' : production? ? 'production' : 'test'

# @logger.info "Application Started: #{Time.now} in #{@environment} environment."

configure do
  dbconfig = YAML.load(File.open('config/database.yml'))[@environment]

  # ActiveRecord::Base.logger = @logger
  ActiveRecord::Base.establish_connection(dbconfig)
  # ActiveRecord::Base.colorize_logging = false
end


get '/' do
  "This is a initial test!"
end

# list all users
get '/users/?' do
  content_type 'application/xml', :charset => 'utf-8'

  @users = User.find(:all)

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!
  xml.result(:code=>"200", :description =>"OK") do |result|
    result.node(:id => "0", 
                :name=>"http://www.steirischerherbst.at",
                :description=>"http://www.steirischerherbst.at") do |node|
      @users.each do |user|
        xml.node(:id => "#{user.id}",
                 :name => "#{user.lastname} #{user.firstname}", 
                 :email=>"#{user.email}")
      end unless @users.nil?
    end
  end
end

# New user
get '/users/new/?' do
  @user = User.new
  erb :new
end

# Show user
get '/users/:id' do
  content_type 'application/xml', :charset => 'utf-8'

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!

  begin
    @user = User.find(params[:id])
    xml.node(:id => "#{@user.id}",
             :name => "#{@user.lastname} #{@user.firstname}", 
             :email => "#{@user.email}")
  rescue ActiveRecord::RecordNotFound => err
    xml.result(:code=>"404", :description=> "Record Not found")
    throw :halt, [404, xml.target!]
  end
end

# Create user
post '/users/?' do
  content_type 'application/xml', :charset => 'utf-8'

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!

  @user = User.new(params[:user])
  if @user.save
    xml.result(:code=>"200", :description =>"OK") do |result|
      result.node(:id => "#{@user.id}", 
                  :name => "#{@user.lastname} #{@user.firstname}", 
                  :email=>"#{@user.email}")
    end
  else
    xml.result(:code => "400", :description => "Bad Request") do |result|
      result.errors do |item|
        @user.errors.each do |field, msg|
          item.error(:field => "#{field}", :message => "#{msg}")
        end
      end
    end
  end
end

# Update user
put '/users/:id' do
  content_type 'application/xml', :charset => 'utf-8'

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!

  begin
    @user.find(params[:id])

    if (@user.update_attributes(params[:user]))
        xml.result(:code=>"200", :description =>"OK") do |result|
          result.node(:id => "#{@user.id}",
                      :name => "#{@user.lastname} #{@user.firstname}",
                      :email => "#{@user.email}")
        end
    else
      xml.result(:code => "400", :description => "Bad Request") do |result|
        result.errors do |item|
          @user.errors.each do |field, msg|
            item.error(:field => "#{field}", :message => "#{msg}")
          end
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    xml.result(:code=>"404", :description=> "Record Not found")
    throw :halt, [404, xml.target!]
  end
end

# Destroy user
delete '/users/:id' do
  content_type 'application/xml', :charset => 'utf-8'

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!

  begin
    @user.find(params[:id])
    @user.destroy

    xml.result(:code=>"200", :description =>"OK") 
  rescue ActiveRecord::RecordNotFound
    xml.result(:code=>"404", :description=> "Record Not found")
    throw :halt, [404, xml.target!]
  end
end

# Edit user
get '/users/:id/edit/?' do
  begin
    @user = User.find(params[:id])
    erb :edit
  rescue ActiveRecord::RecordNotFound
    throw :halt, [404, "RecordNotFound"]
  end
end
