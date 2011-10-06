Lolita.setup do |config|
  # ==> User and authentication configuration
  # Add one or more of your user classes to Lolita
  # config.user_classes << MyUser
  # config.authentication = :authenticate_user!
  
  # Define authentication for Lolita controllers.
  # Call some of your own methods
  # config.authentication=:is_admin?
  # Or use some customized logic
  # config.authentication={
  #  current_user.is_a?(Admin) || current_user.has_role?(:admin)
  # }
  I18n.backend = Lolita::I18n.load Redis.new(:db => 11)
end