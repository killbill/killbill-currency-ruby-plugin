require 'time'

require 'killbill'

require 'currency_plugin/models/currency_rate'
require 'currency_plugin/models/currency_update'

module Killbill
  module CurrencyPlugin
    class DefaultPlugin < Killbill::Plugin::Currency

      def self.initialize!
        require 'active_record'
        require 'active_record/bogacs'
        require 'arjdbc'

        ::ActiveRecord::ConnectionAdapters::ConnectionHandler.connection_pool_class = ::ActiveRecord::Bogacs::FalsePool
        db_config = {
            :adapter              => :mysql,
            # See KillbillActivator#KILLBILL_OSGI_JDBC_JNDI_NAME
            :data_source          => Java::JavaxNaming::InitialContext.new.lookup('killbill/osgi/jdbc'),
            # Since AR-JDBC 1.4, to disable session configuration
            :configure_connection => false
        }
        ActiveRecord::Base.establish_connection(db_config)
      end

      def start_plugin
        super
        DefaultPlugin.initialize!
      end

      # return DB connections to the Pool if required
      def after_request
        ActiveRecord::Base.connection.close
      end

      def get_base_currencies(options = {})
        (Killbill::CurrencyPlugin::CurrencyUpdate.distinct_base_currencies || []).map do |c|
          c.base_currency
        end
      end

      def get_latest_conversion_date(base_currency, options = {})
        res = Killbill::CurrencyPlugin::CurrencyUpdate.latest_base_currency(base_currency)
        res[0].conversion_date.utc unless res.size == 0
      end

      def get_conversion_dates(base_currency, options = {})
        (Killbill::CurrencyPlugin::CurrencyUpdate.historical_base_currencies(base_currency) || []).map do |r|
          r.conversion_date.utc
        end
      end

      def get_current_rates(base_currency, options = {})
        base_latest = Killbill::CurrencyPlugin::CurrencyUpdate.latest_base_currency(base_currency)
        if base_latest.nil? || base_latest.size == 0
          return []
        end

        get_rates_for_currency_update(base_latest[0].id, base_currency, base_latest[0].conversion_date)
      end

      def get_rates(base_currency, conversion_date, options = {})
        (Killbill::CurrencyPlugin::CurrencyUpdate.historical_base_currencies(base_currency) || []).each do |e|
          if Time.at(e.conversion_date) <= Time.at(conversion_date)
            return get_rates_for_currency_update(e.id, base_currency, e.conversion_date)
          end
        end
        []
      end

      private

      def get_rates_for_currency_update(currency_update_id, base_currency, conversion_date)
        (Killbill::CurrencyPlugin::CurrencyRate.latest_rates_for_base_currency(currency_update_id) || []).map do |r|
          rate = Killbill::Plugin::Model::Rate.new
          rate.base_currency = base_currency
          rate.currency = r.target_currency
          rate.value = r.rate
          rate.conversion_date = conversion_date
          rate
        end
      end

    end
  end
end
