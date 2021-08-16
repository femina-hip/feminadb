class AddSchoolLevelsAndBoarding < ActiveRecord::Migration[5.1]
  def change
    add_column(
      :customers,
      :secondary_school_levels_a,
      :boolean,
      null: false,
      comment: 'If True, teaches A-level; if _a and _o are both False, unknown',
      default: false
    )
    add_column(
      :customers,
      :secondary_school_levels_o,
      :boolean,
      null: false,
      comment: 'If True, teaches O-level; if _a and _o are both False, unknown',
      default: false
    )
    add_column(
      :customers,
      :secondary_school_residence_boarding,
      :boolean,
      null: false,
      comment: 'If True, some students board; if _boarding and _day are both False, unknown',
      default: false
    )
    add_column(
      :customers,
      :secondary_school_residence_day,
      :boolean,
      null: false,
      comment: 'If True, some students go home at night; if _boarding and _day are both False, unknown',
      default: false
    )
    # The name "sex" is because Tanzania's government and schools will all
    # use that word. A boy-born-as-a-girl will be sent to a girls school.
    add_column(
      :customers,
      :secondary_school_sexes_boys,
      :boolean,
      null: false,
      comment: 'If True, some students are boys; if _boys and _girls are both False, unknown',
      default: false
    )
    add_column(
      :customers,
      :secondary_school_sexes_girls,
      :boolean,
      null: false,
      comment: 'If True, some students are girls; if _boys and _girls are both False, unknown',
      default: false
    )
  end
end
