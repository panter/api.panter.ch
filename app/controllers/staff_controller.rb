class StaffController < ApiController
  def attributes
    [
      :employees,
      :contractors,
      :hoursWorked,
      :age,
      :commuteDistances,
      :childrenPerEmployee
    ]
  end
end
