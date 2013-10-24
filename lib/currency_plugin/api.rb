require 'date'

require 'killbill/currency'


module Killbill
  module CurrencyPlugin
    class DefaultPlugin < Killbill::Plugin::Currency

      def start_plugin
        super
      end

      def initialize()
        @raise_exception = false
        super()
      end


      def get_base_currencies(options = {})
        return ['USD']
      end

      def get_latest_conversion_date(base_currency, options = {})
        return Time.now
      end

      def get_conversion_dates(base_currency, options = {})
        return [Time.now]
      end

      def get_current_rates(base_currency, options = {})
        rate = Killbill::Plugin::Model::Rate.new()
        rate.base_currency = base_currency
        rate.currency = 'BRL'
        rate.value = 12.3
        rate.conversion_date = Time.now
        return [rate]
      end

      def get_rates(base_currency, conversion_date, options = {})
        rate = Killbill::Plugin::Model::Rate.new()
        rate.base_currency = base_currency
        rate.currency = 'BRL'
        rate.value = 12.3
        rate.conversion_date = Time.now
        return [rate]
      end
    end
  end
end
