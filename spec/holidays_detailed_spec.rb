# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yaml'
require 'json'
require 'date'
require 'google_holiday_calendar'

context 'Check holidays_detailed.yml by Google Calendar' do
  before do
    today = Date::today
    start_date = today - 365
    end_date = start_date + 365 * 2

    @holidays_detailed = YAML.load_file(File.expand_path('../../holidays_detailed.yml', __FILE__))
    @google_calendar = GoogleHolidayCalendar::Calendar.new(country: 'japanese', lang: 'ja', api_key: ENV['GOOGLE_CALENDAR_API_KEY'])
    @gholidays = @google_calendar.holidays(start_date: start_date, end_date: end_date, limit: 50)
    @span = @holidays_detailed.select do |date|
      date.between?(start_date, end_date)
    end
  end

  it 'Google calendar result should have date of holidays_detailed.yml' do
    @span.each do |date|
      expect(@google_calendar.holiday?(date[0])).to eq true
    end
  end

  it 'holidays_detailed.yml shoud have date of Google calendar' do
    @gholidays.each do |date, name|
      expect(@holidays_detailed.key?(date)).to eq true
    end
  end

  it 'holidays_detailed.yml should have holiday in lieu of `Mountain Day`' do
    expect(@holidays_detailed.key?(Date::parse('2019-08-12'))).to eq true
    expect(@holidays_detailed.key?(Date::parse('2024-08-12'))).to eq true
    expect(@holidays_detailed.key?(Date::parse('2030-08-12'))).to eq true
    expect(@holidays_detailed.key?(Date::parse('2041-08-12'))).to eq true
    expect(@holidays_detailed.key?(Date::parse('2047-08-12'))).to eq true
  end

  it 'holidays_detailed.yml should have date of holiday.yml' do
    holidays = YAML.load_file(File.expand_path('../../holidays.yml', __FILE__))
    @holidays_detailed.each do |date, detail|
      expect(holidays.key?(date)).to eq true
      expect(holidays[date]).to eq detail['name']
    end
    expect(holidays.length).to eq @holidays_detailed.length
  end
end
