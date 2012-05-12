require 'uuid_tools/uuid'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_uuid_cookie

  protected

  # This UUID will be added to the episodejs beacon params
  def set_uuid_cookie
    uuid = cookies[:uuid] || UUIDTools::UUID.random_create.to_s
    cookies[:uuid] = { value: uuid, expires: 5.years.from_now }
  end
end
