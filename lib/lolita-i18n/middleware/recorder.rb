module Lolita
  module I18n
    class Recorder
      def initialize(app, options = {})
        @app, @options = app, options
        Lolita.i18n.set_recording_request_path_info
      end

      def call(env)
        Lolita.i18n.request_path_info = env['PATH_INFO']
        @app.call(env)
      end
    end
  end
end
