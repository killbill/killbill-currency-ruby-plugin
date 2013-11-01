module Killbill::CurrencyPlugin
  class Properties
    def initialize(file = 'currency.yml')
      @config_file = Pathname.new(file).expand_path
    end

    def parse!
      raise "#{@config_file} is not a valid file" unless @config_file.file?
      @config = YAML.load_file(@config_file.to_s)
      validate!
    end

    def [](key)
      @config[key]
    end

    private

    def validate!
      raise "Bad configuration for CurrencyPlugin plugin. Config is #{@config.inspect}" if @config.blank? ||
                                                                                          @config[:database].blank?
    end
  end
end
