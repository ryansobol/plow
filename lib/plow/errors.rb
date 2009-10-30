# encoding: UTF-8

class Plow
  # Should be raised when the current process is owned by a non-root user.
  class NonRootProcessOwnerError < StandardError
  end
  
  # Should be raised when the user-supplied system user name is invalid.
  class InvalidSystemUserNameError < StandardError
  end
  
  # Should be raised when the user-supplied web-site name is invalid.
  class InvalidWebSiteNameError < StandardError
  end
  
  # Should be raised when the user-supplied web-site alias is invalid.
  class InvalidWebSiteAliasError < StandardError
  end
  
  # Should be raised when the user-supplied system user name is reserved.
  class ReservedSystemUserNameError < StandardError
  end
  
  # Should be raised when the user-supplied system user name is not found when it should be.
  class SystemUserNameNotFoundError < StandardError
  end
  
  # Should be raised when an application root path already exists when it should not.
  class AppRootAlreadyExistsError < StandardError
  end
  
  # Should be raised when a configuration file already exsits when it should not.
  class ConfigFileAlreadyExistsError < StandardError
  end
end