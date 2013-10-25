module Killbill
  module CurrencyPlugin
    class CurrencyUpdate < ActiveRecord::Base

      has_many :currency_rates

      attr_accessible :base_currency,
                      :conversion_date

      scope :historical_base_currencies, -> (base_currency_arg) { where("base_currency = ?", base_currency_arg) }
      scope :latest_base_currency, -> (base_currency_arg) { historical_base_currencies(base_currency_arg).order("conversion_date DESC").limit(1) }
      scope :distinct_base_currencies, -> { select("DISTINCT base_currency") }
    end
  end
end