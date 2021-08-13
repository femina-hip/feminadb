class AddSchoolLevelsAndBoarding < ActiveRecord::Migration[5.1]
  def change
    add_column(
      :customers,
      :school_levels_and_boarding,
      "ENUM('a_boarding', 'a_day', 'a_boarding_o_day', 'ao_boarding', 'ao_day', 'o_boarding', 'o_day')",
      default: nil
    )
  end
end
