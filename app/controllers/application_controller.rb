class PageNotFoundError < StandardError;end

class ApplicationController < ActionController::Base

  ERRORS_MAPPER = {
    'PageNotFoundError' => '404',
  }
  rescue_from PageNotFoundError do |exception|
    render template: "errors/#{ERRORS_MAPPER.fetch(exception.class.name, 'unknown')}", layout: false
  end
  
end
