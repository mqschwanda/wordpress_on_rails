module CurrentUserHelper
  def current_user
    return @cama_current_user if defined?(@cama_current_user)
    # api current user...
    @cama_current_user = cama_calc_api_current_user
    return @cama_current_user unless @cama_current_user.nil?

    return nil unless cookies[:auth_token].present?
    c = cookies[:auth_token].split("&")
    return nil unless c.size == 3

    if c[1] == request.user_agent && request.ip == c[2]
      @cama_current_user = (current_site.users_include_admins.find_by_auth_token(c[0]).decorate rescue nil)
    end
  end

  private
  # calculate the current user for API
  def cama_calc_api_current_user
    current_site.users_include_admins.find(doorkeeper_token.resource_owner_id).decorate if doorkeeper_token rescue nil
  end

  def verify_access
    result = RailsDb.verify_access_proc.call(self)
    if !current_user || current_user.role != 'admin'
      redirect_to '/admin'
    end
  end
end
