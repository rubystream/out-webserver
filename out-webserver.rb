require 'rubygems'
require 'sinatra'
require 'active_record'
require 'builder'
require 'yaml'

# Load models
Dir.glob(File.join(File.dirname(__FILE__), './db/models/*.rb')).each {|f| require f }

enable :sessions
enable :logging

logFile = File.open('log/database.log','a+')
@logger = Logger.new(logFile)
@logger.level = Logger::INFO

@environment =  ENV['RACK_ENV'] || development? ? 'development' : production? ? 'production' : 'test'

@logger.info "Application Started: #{Time.now} in #{@environment} environment."

configure do
  dbconfig = YAML.load(File.open('config/database.yml'))[@environment]

  ActiveRecord::Base.logger = @logger
  ActiveRecord::Base.establish_connection(dbconfig)
  ActiveRecord::Base.colorize_logging = false
end


get '/' do
  "This is a initial test!"
end

get '/users' do
  content_type 'application/xml', :charset => 'utf-8'

  @users = User.find(:all)

  xml = Builder::XmlMarkup.new :indent => 2
  xml.instruct!
  xml.node(:name=>"http://www.steirischerherbst.at",
           :description=>"http://www.steirischerherbst.at") do |node|
    @users.each do |user|
      xml.node(:name => "#{user.lastname} #{user.firstname}" :email=>"#{user.email}")
    end unless @users.nil?
  end

end
