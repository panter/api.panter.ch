class RootController < ApplicationController
  def index
    render json: controller_entries
  end

  private

  def controller_entries
    [:code, :staff, :salary, :performance].map do |controller|
      controller_entry(controller)
    end.to_h
  end

  def controller_entry(controller)
    ["#{controller}_url", url_for(controller: controller, action: :show)]
  end
end
