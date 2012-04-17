
Lolita.setup do |config|
  config.i18n.store = Redis.new({:db => 0})
end
