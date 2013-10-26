require 'spec_helper'

require 'time'

describe Killbill::CurrencyPlugin::DefaultPlugin do

  before(:each) do
    Killbill::CurrencyPlugin::CurrencyUpdate.delete_all
    Killbill::CurrencyPlugin::CurrencyRate.delete_all
  end


  it 'should test plugin apis with no data' do

    api = Killbill::CurrencyPlugin::DefaultPlugin.new

    base_currencies = api.get_base_currencies
    base_currencies.size.should == 0

    usd_latest_conversion_date = api.get_latest_conversion_date('USD')
    usd_latest_conversion_date.should be_nil

    conversion_dates = api.get_conversion_dates('EUR')
    conversion_dates.size.should == 0

    rates = api.get_current_rates('USD')
    rates.size.should == 0

    rates = api.get_rates('USD', Time.now)
    rates.size.should == 0
  end

  it 'should test plugin apis' do

    api = Killbill::CurrencyPlugin::DefaultPlugin.new

    d1 = Time.parse('2013-10-1T20:41:09Z')
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d1
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d1
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d1

    d2 = Time.parse('2013-10-2T21:32:07Z')
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d2
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d2
    Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d2

    d3 = Time.parse('2013-10-3T21:42:07Z')
    usd_d3 = Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'USD',
                                                    :conversion_date => d3
    eur_d3 = Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'EUR',
                                                    :conversion_date => d3
    brl_d3 = Killbill::CurrencyPlugin::CurrencyUpdate.create :base_currency => 'BRL',
                                                    :conversion_date => d3


    base_currencies = api.get_base_currencies
    base_currencies.size.should == 3
    base_currencies[0].should == 'BRL'
    base_currencies[1].should == 'EUR'
    base_currencies[2].should == 'USD'

    usd_latest_conversion_date = api.get_latest_conversion_date('USD')
    Time.at(usd_latest_conversion_date).should == Time.at(d3)

    conversion_dates = api.get_conversion_dates('EUR')
    conversion_dates.size.should == 3
    Time.at(conversion_dates[0]).should == Time.at(d3)
    Time.at(conversion_dates[1]).should == Time.at(d2)
    Time.at(conversion_dates[2]).should == Time.at(d1)


    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'BRL',
                                                  :rate => 0.45731,
                                                  :currency_update_id => usd_d3.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'EUR',
                                                  :rate => 1.38055,
                                                  :currency_update_id => usd_d3.id

    Killbill::CurrencyPlugin::CurrencyRate.create :target_currency => 'GBP',
                                                  :rate => 1.61660,
                                                  :currency_update_id => usd_d3.id

    rates = api.get_current_rates('USD')
    rates.size.should == 3

    rates[0].base_currency.should == 'USD'
    rates[0].currency.should == 'BRL'
    rates[0].value.should == 0.45731
    Time.at(rates[0].conversion_date).should == Time.at(d3)

    rates[1].base_currency.should == 'USD'
    rates[1].currency.should == 'EUR'
    rates[1].value.should == 1.38055
    Time.at(rates[1].conversion_date).should == Time.at(d3)

    rates[2].base_currency.should == 'USD'
    rates[2].currency.should == 'GBP'
    rates[2].value.should == 1.61660
    Time.at(rates[2].conversion_date).should == Time.at(d3)


    rates = api.get_rates('USD', d2)
    rates.size.should == 0

    rates = api.get_rates('USD', d3)
    rates.size.should == 3

  end
end
