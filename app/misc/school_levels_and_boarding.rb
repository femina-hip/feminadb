module SchoolLevelsAndBoarding
  # Database values are ENUM or NULL.
  # Ruby-side values are strings, possibly-empty.
  VALUES = {
    'a_boarding' => 'A-level, boarding',
    'a_day' => 'A-level, day',
    'a_boarding_o_day' => 'A- and O-level: A boarding, O day',
    'ao_boarding' => 'A- and O-level, boarding',
    'ao_day' => 'A- and O-level, day',
    'o_boarding' => 'O-level, boarding',
    'o_day' => 'O-level, day',
    '' => 'Unknown'
  }

  def self.describe(value)
    VALUES[value]
  end
end
