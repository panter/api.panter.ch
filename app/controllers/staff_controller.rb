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

  api :show, 'GET staff' do
    desc 'The staff endpoint returns data related to employment and staffing.'

    response :success, '', :json, data: {
      employees!: {
        count!: { type: Integer, example: 45 },
        historicCount!: [{
          date!: { type: String, example: '2006-06-01' },
          count!: { type: Integer, example: 1 }
        }],
      },
      contractors!: {
        count!: { type: Integer, example: 37 }
      },
      hoursWorked!: {
        currentMonth!: { type: Integer, example: 2220 }
      },
      age!: {
        average!: { type: Integer, example: 34 }
      },
      commuteDistances!: {
        shortest!: {
          duration!: { type: String, example: '13min' },
          distance!: { type: String, example: '0.9km' }
        },
        longest!: {
          duration!: { type: String, example: '2.85h' },
          distance!: { type: String, example: '135.3km' }
        },
      },
      childrenPerEmployee!: {
        count!: { type: Float, example: 0.67 }
      }
    }
  end
end
