class PerformanceController < ApplicationController
  include OpenApi::DSL

  def show
    start_date =
      if params[:start_date].present?
        DateTime.parse(params[:start_date])
      else
        DateTime.current.beginning_of_year
      end

    end_date =
      if params[:end_date].present?
        DateTime.parse(params[:end_date])
      else
        DateTime.current.end_of_year
      end

    entries = (start_date..end_date).select{ |date| date.day == 1 }.map do |date|
      DataStore.get("performance_#{date.beginning_of_month.strftime('%F')}")
    end.compact

    render json: { performance: entries }
  end

  api :show, 'GET performance' do
    desc 'The performance endpoint returns data related to the performance.'

    query :start_date, Date, example: '2016-03-01', default: '&lt;CURRENT YEAR&gt;-01-01'
    query :end_date, Date, example: '2017-05-01', default: '&lt;CURRENT YEAR&gt;-12-31'

    response :success, '', :json, data: {
      performance!: [{
        startDate!: { type: String, example: '2016-03-01' },
        endDate!: { type: String, example: '2016-03-31' },
        hours!: {
          billable!: { type: Float, example: 2404.2 },
          nonBillable!: { type: Float, example: 885.5 },
          neutral!: { type: Float, example: 187 },
          total!: { type: Float, example: 3476.7 }
        },
        performance!: { type: Float, example: 0.73 }
      }]
    }
  end
end
