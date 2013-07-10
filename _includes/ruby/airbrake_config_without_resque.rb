Airbrake.configure do |config|
  # ...
  config.async do |notice|
    MicroAwesomeService::Queue.add('normal', "AirbrakeDeliveryWorker", notice.to_xml)
  end
end
