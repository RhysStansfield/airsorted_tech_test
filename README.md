Super simple implementation of occupancy calculator task from AirSorted tech test.

For the sake of simplicity this system makes several assumptions:
* No overlapping bookings or unavailable_periods will be passed in (i.e. `[{ start: 5-6-2015, end: 10-6-2015 }, { start: 8-6-2015, end: 14-6-2015 }]`)
* The day that a guest leaves is considered to be a day of occupation as well - the system could be expanded to take into account the actual time of day of leaving/arriving, but I felt it to be beyond the scope of this exercise

Design Decisions:
* Simple PORO objects, no included libraries except for time and date from the stdlib (and minitest and minitest/pride, also of stdlib, for testing)
* Minitest used as test framework for it's simplicity, speed and ease of use
* As far as is reasonable (and readable) all public api methods attempt to keep to a single clearly explicit line of code, more complex code is delegated to private methods
* Only public api methods specifically tested - private methods are used by public methods as implementation details, therefore if public methods are working as expected so are the private methods
* A couple of methods have only minor differences in implementation, NOLOC could be reduced with some simple metaprogramming for these, but I felt at the cost of clarity and readability

Areas for Improvement:
* `#count_relevant_from` has too many conditionals, thought about a more elegant way of achieving the same result required
* Cluttered public api - some of these methods could likely be moved to private
* More detailed documentation

Run the test suite:

  `~/path_to/airsorted_tech_test: ruby occupancy_calculator_test.rb`

Watch out for mosquitos
