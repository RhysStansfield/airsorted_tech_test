require 'time'
require 'date'

class OccupancyCalculator
  attr_accessor :time_period, :bookings, :days_in_month, :unavailable_periods

  # args:
  #   time_period - should be a time object that represents the month we are
  #   calculating the average occupancy for

  #   bookings - should be an array of hashes, each with start and end keys, the
  #   values of which should be Time objects

  #   unavailable_periods - exact same format as bookings, but representing periods of time
  #   during which the property is unavailable, defaults to empty array
  def initialize(time_period, bookings, unavailable_periods = [])
    self.time_period         = time_period
    self.bookings            = bookings
    self.days_in_month       = Date.new(time_period.year, time_period.month, -1).day
    self.unavailable_periods = unavailable_periods
  end

  # compile all information, returns hash
  def result
    {
      days_occupied_percent: calculate_days_occupied_percent,
      nights_occupied:       nights_occupied_fractional,
      nights_available:      nights_available_fractional
    }
  end

  # calculates available days in time period, returns integer
  def available_days
    days_in_month - unavailable_days
  end

  # calculates available nights in time period, returns integer
  def available_nights
    days_in_month - unavailable_nights
  end

  # calculates unavailable days in time period, returns integer
  def unavailable_days
    unavailable_periods.inject(0, &method(:accumulate_days))
  end

  # calculates unavailable nights in time period, returns integer
  def unavailable_nights
    unavailable_periods.inject(0, &method(:accumulate_nights))
  end

  # calculates occupancy percentage for time period, returns integer from 0 to 100
  def calculate_days_occupied_percent
    ((num_occupied_days.to_f / available_days) * 100).round
  end

  # calculates number of nights available during the time period, returns integer
  def calculate_nights_available
    available_nights - calculate_nights_occupied
  end

  def nights_available_fractional
    "#{calculate_nights_available}/#{available_nights}#{extra_fractional_info}"
  end

  # calculates number of nights occupied during the time period, returns integer
  def calculate_nights_occupied
    @nights_occupied ||= bookings.inject(0, &method(:accumulate_nights))
  end

  # fractional representation of nights occupied vs days in month, returns string
  def nights_occupied_fractional
    "#{calculate_nights_occupied}/#{available_nights}#{extra_fractional_info}"
  end

  # number of days of occupation for the time period from bookings, returns integer
  def num_occupied_days
    bookings.inject(0, &method(:accumulate_days))
  end

  # args:
  #   booking should be a hash with start/end keys, each of which has a Time object for it's value

  # returns an integer representing number of relevant days of occupation for the time period
  # from a booking
  def count_relevant_days_from(booking)
    count_relevant_from(booking, 1)
  end

  # args:
  #   booking should be a hash with start/end keys, each of which has a Time object for it's value

  # returns an integer representing number of relevant nights of occupation for the time period
  # from a booking
  def count_relevant_nights_from(booking)
    count_relevant_from(booking)
  end

  private

  def accumulate_days(acc, booking)
    acc + count_relevant_days_from(booking)
  end

  def accumulate_nights(acc, booking)
    acc + count_relevant_nights_from(booking)
  end

  def extra_fractional_info
    days_in_month != available_nights ? " (of #{days_in_month})" : ''
  end

  # Default return value for #count_relevant_from
  DEFAULT_RELEVANT_AMOUNT = 0

  def count_relevant_from(booking, offset = 0)
    if !booking_valid_and_relevant?(booking)
      return DEFAULT_RELEVANT_AMOUNT
    end

    if booking[:start].month < time_period.month && booking[:end].month > time_period.month
      return days_in_month
    end

    if start_and_end_dates_within_time_period?(booking)
      return (booking[:end].day - booking[:start].day) + offset
    end

    if year_and_month_eq_time_period_year_and_month?(booking[:start])
      return (days_in_month - booking[:start].day) + offset
    end

    if year_and_month_eq_time_period_year_and_month?(booking[:end])
      return booking[:end].day
    end

    DEFAULT_RELEVANT_AMOUNT
  end

  def start_and_end_dates_within_time_period?(booking)
    year_and_month_eq_time_period_year_and_month?(booking[:start]) &&
      year_and_month_eq_time_period_year_and_month?(booking[:end])
  end

  def year_and_month_eq_time_period_year_and_month?(time)
    [time.year, time.month] == [time_period.year, time_period.month]
  end

  def booking_valid_and_relevant?(booking)
    return false if booking[:start] > booking[:end]
    return false if booking[:start] == booking[:end]
    return false if booking[:end].year < time_period.year
    return false if booking[:end].month < time_period.month
    return false if booking[:start].year > time_period.year
    return false if booking[:start].month > time_period.month
    true
  end
end
