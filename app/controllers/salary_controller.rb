class SalaryController < ApplicationController
  def show
    render json: {
      :'performance' => DataStore.get('performance'),
      :'salaries' => DataStore.get('salaries')
    }
  end
end
