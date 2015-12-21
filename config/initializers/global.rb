class CustomLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end

logfile = File.open(Rails.root.join('log/custom.log'), 'a')  # create log file
logfile.sync = true  # automatically flushes data to file

IntelSapr.setLogger(CustomLogger.new(logfile))

Global.configure do |config|
	config.environment = Rails.env.to_s
	config.config_directory = Rails.root.join('config/global').to_s
end
