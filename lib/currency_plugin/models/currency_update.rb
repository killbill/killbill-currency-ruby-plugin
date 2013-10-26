module Killbill
  module CurrencyPlugin
    class CurrencyUpdate < ActiveRecord::Base

      has_many :currency_rates

      attr_accessible :base_currency,
                      :conversion_date

      scope :historical_base_currencies, ->(base_currency_arg) { where("base_currency = ?", base_currency_arg).order("conversion_date DESC") }
      scope :latest_base_currency, ->(base_currency_arg) { historical_base_currencies(base_currency_arg).limit(1) }
      scope :distinct_base_currencies, -> { select("DISTINCT base_currency").order("base_currency ASC") }

      #scope :latest_rates_for_currency, ->(base_currency_arg) { latest_base_currency(base_currency_arg).joins(:currency_rates).order("target_currency ASC")  }
    end
  end
end