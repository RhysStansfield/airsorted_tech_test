require 'minitest/autorun'
require 'minitest/pride'

require_relative 'occupancy_calculator'

class OccupancyCalculatorTest < Minitest::Test
  def test_sets_time_period_and_bookings
    time_p, bookings, occupancy_calc = _test_data_1

    assert_equal time_p, occupancy_calc.time_period
    assert_equal bookings, occupancy_calc.bookings
  end

  def test_sets_days_in_month
    occupancy_calc_1 = _test_data_1.last
    occupancy_calc_2 = _test_data_1(7).last
    occupancy_calc_3 = _test_data_1(2).last

    assert_equal 30, occupancy_calc_1.days_in_month
    assert_equal 31, occupancy_calc_2.days_in_month
    assert_equal 28, occupancy_calc_3.days_in_month
  end

  def test_count_relevant_days_from_booking
    occupancy_calc = add_more_bookings(_test_data_1.last)

    assert_equal 6,  occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[0])
    assert_equal 0,  occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[1])
    assert_equal 6,  occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[2])
    assert_equal 10, occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[3])
    assert_equal 30, occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[4])
    assert_equal 0,  occupancy_calc.count_relevant_days_from(occupancy_calc.bookings[5])
  end

  def test_num_relevant_days_from_bookings
    occupancy_calc = _test_data_1.last
    occupancy_calc.bookings.push(
      { start: Time.new(2015, 6, 25), end: Time.new(2015, 7, 5) }
    )

    assert_equal 12, occupancy_calc.num_occupied_days
  end

  def test_calculate_days_occupied_percent
    occupancy_calc = _test_data_1.last
    occupancy_calc.bookings << { start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 9) }

    assert_equal 50, occupancy_calc.calculate_days_occupied_percent

    occupancy_calc.bookings << { start: Time.new(2015, 6, 25), end: Time.new(2015, 7, 5) }

    assert_equal 70, occupancy_calc.calculate_days_occupied_percent
  end

  def test_count_relevant_nights_from_booking
    occupancy_calc = add_more_bookings(_test_data_1.last)

    assert_equal 5,  occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[0])
    assert_equal 0,  occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[1])
    assert_equal 5,  occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[2])
    assert_equal 10, occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[3])
    assert_equal 30, occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[4])
    assert_equal 0,  occupancy_calc.count_relevant_nights_from(occupancy_calc.bookings[5])
  end

  def test_cacluate_nights_occupied
    occupancy_calc = _test_data_1.last
    assert_equal 5, occupancy_calc.calculate_nights_occupied
  end

  def test_nights_occupied_fractional
    occupancy_calc = _test_data_1.last

    assert_equal '5/30', occupancy_calc.nights_occupied_fractional

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal '5/26 (of 30)', occupancy_calc.nights_occupied_fractional
  end

  def test_calculate_nights_available
    occupancy_calc = _test_data_1.last
    assert_equal 25, occupancy_calc.calculate_nights_available
  end

  def test_nights_available_fractional
    occupancy_calc = _test_data_1.last

    assert_equal '25/30', occupancy_calc.nights_available_fractional

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal '21/26 (of 30)', occupancy_calc.nights_available_fractional
  end

  def test_result
    occupancy_calc  = _test_data_1.last
    expected_result = {
      days_occupied_percent: 20,
      nights_occupied:       '5/30',
      nights_available:      '25/30'
    }

    assert_equal expected_result, occupancy_calc.result
  end

  def test_available_days
    occupancy_calc = _test_data_1.last

    assert_equal 30, occupancy_calc.available_days

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal 25, occupancy_calc.available_days
  end

  def test_unavailable_days
    occupancy_calc = _test_data_1.last

    assert_equal 0, occupancy_calc.unavailable_days

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal 5, occupancy_calc.unavailable_days
  end

  def test_available_nights
    occupancy_calc = _test_data_1.last

    assert_equal 30, occupancy_calc.available_nights

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal 26, occupancy_calc.available_nights
  end

  def test_unavailable_nights
    occupancy_calc = _test_data_1.last

    assert_equal 0, occupancy_calc.unavailable_nights

    occupancy_calc.unavailable_periods << {
      start: Time.new(2015, 6, 1), end: Time.new(2015, 6, 5)
    }

    assert_equal 4, occupancy_calc.unavailable_nights
  end

  private

  def _test_data_1(month = 6)
    time_p   = Time.new(2015, month)
    start_t  = Time.new(2015, month, 10)
    end_t    = Time.new(2015, month, 15)
    bookings = [{ start: start_t, end: end_t }]

    return time_p, bookings, OccupancyCalculator.new(time_p, bookings)
  end

  def add_more_bookings(occupancy_calc)
    occupancy_calc.bookings += [
      { start: Time.new(2015, 6, 25), end: Time.new(2015, 6, 20) },
      { start: Time.new(2015, 6, 25), end: Time.new(2015, 7, 5)  },
      { start: Time.new(2015, 5, 25), end: Time.new(2015, 6, 10) },
      { start: Time.new(2015, 5, 25), end: Time.new(2015, 7, 10) },
      { start: Time.new(2014, 5, 25), end: Time.new(2014, 7, 10) }
    ]

    occupancy_calc
  end
end
