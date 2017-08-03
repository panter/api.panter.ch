class RootController < ApplicationController
  def index
    render json: controller_entries
  end

  private

  def controller_entries
    [
      :code,
      :staff,
      :salary,
      [:performance, { start_date: '2016-03-01', end_date: '2017-05-01' }]
    ].map do |controller, params = {}|
      controller_entry(controller, params)
    end.to_h
  end

  def controller_entry(controller, params)
    ["#{controller}_url", url_for(controller: controller, action: :show, **params)]
  end
end
