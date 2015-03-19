# encoding: UTF-8

require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'hours.rb')

class TestBasic < Test::Unit::TestCase
  def test_simple_inverted_sentences
    {
      '7:00 to 11:00 on Sunday' => 'S0:0700-1100',
      '15:00 to 1:00 Sunday' => 'S0:1500-2500',
      '07:00-00:00, Sun' => 'S0:0700-2400'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_inverted_through_sentences
    {
      '12:30-01:00 Mon-Sun' => 'S0-6:1230-2500',
      '06:30 - 22:30 on Mon to Sun' => 'S0-6:0630-2230',
      '06:30 - 22:30 Fri to Tue' => 'S5-2:0630-2230',
      '07:00-01:00 Mon - Wed' => 'S1-3:0700-2500'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_and
    {
      '09:30-22:30 Mon-Thu & Sun' => 'S0-4:0930-2230',
      '09:30-23:00 Fri-Sat & PH' => 'S5-6:0930-2300'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_multiple_times
    {
      '11:45-16:30, 17:45-23:30 Mon-Fri' => 'S1-5:1145-1630,1745-2330',
      '12:00-15:00, 18:00-22:00 Monday to Sunday' => 'S0-6:1200-1500,1800-2200'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_multiline_hours
    {
      '11:30-22:30 Mon.-Sat.; 10:30-22:30 Sun.' => 'S0:1030-2230;1-6:1130-2230',
      '11:00-23:00 Sun.-Thur., 11:00-00:00 Fri.-Sat.' => 'S0-4:1100-2300;5-6:1100-2400'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_complex_sentences
    {
      "11:00-21:00 on Mon-Sat and until 300 quotas soldout" => 'S1-6:1100-2100'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

  def test_am_pm_modifiers
    {
      'Sunday: 7:00 am to 11:00 am' => 'S0:0700-1100',
      'Sunday: 7:00 am to 11:00 pm' => 'S0:0700-2300',
      'Sunday: 7:00 pm to 11:00 pm' => 'S0:1900-2300',
      '7:00 am to 11:00 am on Sunday' => 'S0:0700-1100',
      '7:00 am to 11:00 pm on Sunday' => 'S0:0700-2300',
      '7:00 pm to 11:00 pm on Sunday' => 'S0:1900-2300',
      '3:00 pm to 1:00 am Sunday' => 'S0:1500-2500',
      '3:00 pm to 1:00 Sunday' => 'S0:1500-2500',
      '07:00 am - 00:00 am, Sun' => 'S0:0700-2400',
      'Mon.-Sat.: 11:30 am -10:30 pm; Sun.: 10:30 am - 22:30' => 'S0:1030-2230;1-6:1130-2230',
      'Sunday: 7:00am to 11:00am' => 'S0:0700-1100',
      'Sunday: 7am to 11am' => 'S0:0700-1100',
      'Sunday: 700am to 1100am' => 'S0:0700-1100',
      'Sunday: 7am to 11pm' => 'S0:0700-2300',
      'Sunday: 1-3pm' => 'S0:1300-1500',
      'Sunday: 9-11am' => 'S0:0900-1100'
    }.each { |k,v| assert_equal(v, Hours.parse(k)) }
  end

end
