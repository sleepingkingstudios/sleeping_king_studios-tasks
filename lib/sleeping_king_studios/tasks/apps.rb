# lib/sleeping_king_studios/tasks/apps.rb

require 'yaml'

require 'sleeping_king_studios/tasks'

module SleepingKingStudios::Tasks
  # Thor tasks for semi-distributed applications.
  module Apps
    autoload :AppConfiguration,
      'sleeping_king_studios/tasks/apps/app_configuration'

    # rubocop:disable Metrics/MethodLength
    def self.configuration
      @configuration ||=
        begin
          tools = SleepingKingStudios::Tools::Toolbelt.instance
          apps  = load_configuration
          hsh   = Hash.new do |_, key|
            SleepingKingStudios::Tasks::Apps::AppConfiguration.
              new(:name => key.to_s)
          end # hash

          apps.each do |key, data|
            name = key.to_s
            data = tools.hsh.convert_keys_to_symbols(data)

            data[:name] ||= name

            hsh[key] =
              SleepingKingStudios::Tasks::Apps::AppConfiguration.new(data)
          end # each

          hsh
        end # begin-end
    end # class method configuration
    # rubocop:enable Metrics/MethodLength

    def self.load_configuration
      config_file = SleepingKingStudios::Tasks.configuration.apps.config_file
      raw         = ::File.read(config_file)

      YAML.safe_load raw
    rescue
      {}
    end # class method load_configuration
    class << self; private :load_configuration; end
  end # module
end # module
