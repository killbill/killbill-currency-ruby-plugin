require 'spec_helper'

require 'time'

describe Killbill::CurrencyPlugin::CurrencyUpdate do

  before(:each) do
    Killbill::CurrencyPlugin::CurrencyUpdate.delete_all
    Killbill::CurrencyPlugin::CurrencyRate.delete_all
  end

  it 'should test currency update scope queries' do

    Killbill::CurrencyPlugin::CurrencyUpdate.historical_base_currencies('EUR').size.should == 0

    d1 = Time.parse('2013-10-25T20:41:09Z')

    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d1
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d1
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d1

    d2 = Time.parse('2013-10-27T21:32:07Z')
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d2
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d2
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d2

    d3 = Time.parse('2013-10-26T21:42:07Z')
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d3
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d3
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d3


    eur_historical = Killbill::CurrencyPlugin::CurrencyUpdate.historical_base_currencies('EUR')
    eur_historical.size.should == 3
    Time.at(eur_historical[0].conversion_date).should == Time.at(d2)
    Time.at(eur_historical[1].conversion_date).should == Time.at(d3)
    Time.at(eur_historical[2].conversion_date).should == Time.at(d1)

    eur_latest = Killbill::CurrencyPlugin::CurrencyUpdate.latest_base_currency('EUR')
    eur_latest.size.should == 1
    eur_latest[0].base_currency.should == 'EUR'
    Time.at(eur_latest[0].conversion_date).should == Time.at(d2)

    distinct_base_currencies = Killbill::CurrencyPlugin::CurrencyUpdate.distinct_base_currencies
    distinct_base_currencies.size.should == 3
    distinct_base_currencies.each_with_index do |c, i|
      c.base_currency.should == 'BRL' if i == 0
      c.base_currency.should == 'EUR' if i == 1
      c.base_currency.should == 'USD' if i == 2
    end
  end

  it 'should test currency rate scope queries' do

    d1 = Time.parse('2013-10-10T20:41:09Z')

    res1 = Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                           :conversion_date => d1

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'BRL',
                                                  :rate => 0.45721,
                                                  :currency_update_id => res1.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'EUR',
                                                  :rate => 1.38045,
                                                  :currency_update_id => res1.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'GBP',
                                                  :rate => 1.61650,
                                                  :currency_update_id => res1.id


    d2 = Time.parse('2013-10-11T20:41:09Z')
    res2 = Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                           :conversion_date => d2

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'BRL',
                                                  :rate => 0.45731,
                                                  :currency_update_id => res2.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'EUR',
                                                  :rate => 1.38055,
                                                  :currency_update_id => res2.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'GBP',
                                                  :rate => 1.61660,
                                                  :currency_update_id => res2.id


    #
    # Can't gte it to work in one join query using scope-- SQL generated is weird:
    # (SELECT COUNT(count_column) FROM (SELECT 1 AS count_column FROM "currency_updates" INNER JOIN "currency_rates" ON "currency_rates"."currency_update_id" = "currency_updates"."id" WHERE (base_currency = 'USD') LIMIT 1) subquery_for_count)
    #
    #latest_rates_for_usd = Killbill::CurrencyPlugin::CurrencyUpdate.latest_rates_for_currency('USD')

    usd_latest = Killbill::CurrencyPlugin::CurrencyUpdate.latest_base_currency('USD')
    latest_rates_for_usd = Killbill::CurrencyPlugin::CurrencyRate.latest_rates_for_base_currency(usd_latest[0].id)
    latest_rates_for_usd.size.should == 3
    latest_rates_for_usd[0].target_currency.should == 'BRL'
    latest_rates_for_usd[0].rate.should == 0.45731
    latest_rates_for_usd[1].target_currency.should == 'EUR'
    latest_rates_for_usd[1].rate.should == 1.38055
    latest_rates_for_usd[2].target_currency.should == 'GBP'
    latest_rates_for_usd[2].rate.should == 1.61660
  end
end