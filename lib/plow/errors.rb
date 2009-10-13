# encoding: UTF-8

class Plow
  class NonRootProcessOwnerError < StandardError
  end
  
  class InvalidSystemUserNameError < StandardError
  end
  
  class InvalidWebSiteNameError < StandardError
  end
  
  class InvalidWebSiteAliasError < StandardError
  end
  
  class ReservedSystemUserNameError < StandardError
  end
  
  class SystemUserNameNotFoundError < StandardError
  end
  
  class AppRootAlreadyExistsError < StandardError
  end
  
  class ConfigFileAlreadyExistsError < StandardError
  end
end