require 'out-webserver'

# sinatra doesn't have anything built in for logging so you can use the stdout to log to a file
log = File.new("log/our-webserver.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)


run Sinatra::Application
