def synchronize(seconds=Capybara.default_wait_time)
  start_time = Time.now

  if session.synchronized
    yield
  else
    session.synchronized = true
    begin
      yield
    rescue => e
      raise e unless driver.wait?
      raise e unless catch_error?(e)
      raise e if (Time.now - start_time) >= seconds
      sleep(0.05)
      raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Time.now == start_time
      reload if Capybara.automatic_reload
      retry
    ensure
      session.synchronized = false
    end
  end
end
