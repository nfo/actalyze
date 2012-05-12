require 'uuid_tools/uuid'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_uuid_cookie

  protected

  def set_uuid_cookie
    cookies[:uuid] ||= UUIDTools::UUID.random_create.to_s
  end
end
