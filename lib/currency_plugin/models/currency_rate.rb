module Killbill
  module CurrencyPlugin

    class CurrencyRate < ActiveRecord::Base

      belongs_to :currency_update

      scope :latest_rates_for_base_currency, ->(currency_update_id) { where("currency_update_id = ?", currency_update_id).order("target_currency ASC") }
    end
  end
end
