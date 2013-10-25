module Killbill
  module CurrencyPlugin

    class CurrencyRate < ActiveRecord::Base

      belongs_to :currency_update

      attr_accessible :base_currency,
                      :target_currency,
                      :rate,
                      :conversion_date

      scope :latest_rates_for_base_currency, -> (base_currency_id, ) { where("currency_update_id = ?", base_currency_id) }
    end
  end
end
