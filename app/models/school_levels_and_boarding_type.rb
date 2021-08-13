class SchoolLevelsAndBoardingType < ActiveRecord::Type::String
  def cast(value)
    if value
      value
    else
      nil
    end
  end

  def deserialize(value)
    if value.nil?
      ''
    else
      value
    end
  end
end

