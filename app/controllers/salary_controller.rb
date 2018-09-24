class SalaryController < ApiController
  def attributes
    [
      [:performance, :currentPerformance],
      :salaries
    ]
  end

  api :show, 'GET salary' do
    desc 'The salary endpoint returns data related to the salary.'

    response :success, '', :json, data: {
      performance!: {
        lastMonth!: { type: Float, example: 0.69, desc: 'The performance of the last but one month (i.e. current month - 2)' },
        secondToLastMonth!: { type: Float, example: 0.59, desc: 'The performance of the last but two month (i.e. current month - 3)' }
      },
      salaries!: {
        oneYearBack!: [{
          month!: { type: Integer, example: 8 },
          year!: { type: Integer, example: 2017 },
          salary!: { type: Integer, example: 6898 },
          workload!: { type: Integer, example: 69, desc: 'The average workload in percent' }
        }],
        twoYearsBack!: [{
          month!: { type: Integer, example: 8 },
          year!: { type: Integer, example: 2016 },
          salary!: { type: Integer, example: 7943, desc: 'The average salary in CHF' },
          workload!: { type: Integer, example: 82, desc: 'The average workload in percent' }
        }]
      }
    }
  end
end
