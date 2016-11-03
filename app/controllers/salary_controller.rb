class SalaryController < ApiController
  def attributes
    [
      :performance,
      :salaries
    ]
  end
end
