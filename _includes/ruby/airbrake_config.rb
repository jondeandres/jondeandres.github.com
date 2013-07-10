Airbrake.configure do |config|
  # ...
  config.async do |notice|
    OurAmaizingQueue.add(AirbrakeDeliveryWorker, notice.to_xml)
  end
end
