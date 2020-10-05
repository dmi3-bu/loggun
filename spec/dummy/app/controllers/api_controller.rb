class ApiController < ApplicationController
  def index
    logger.info 'index'
    HTTP.get('https://google.com')
  end

  def outgoing_request
    HTTP.get('https://google.com')
  end

  def incoming_request
    render 'ok'
  end
end