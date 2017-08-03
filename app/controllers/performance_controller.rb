class PerformanceController < ApplicationController
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
end
