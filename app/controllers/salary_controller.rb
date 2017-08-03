class SalaryController < ApiController
  def attributes
    [
      [:performance, :currentPerformance],
      :salaries
    ]
  end
end
