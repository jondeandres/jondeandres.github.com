def catch_error?(error)
  (driver.invalid_element_errors + [Capybara::ElementNotFound]).any? do |type|
    error.is_a?(type)
  end
end
