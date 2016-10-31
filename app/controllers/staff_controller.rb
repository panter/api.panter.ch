class StaffController < ApplicationController
  def show
    render json: {
      :'employees' => DataStore.get('employees'),
      :'contractors' => DataStore.get('contractors'),
      :'hours-worked' => DataStore.get('hours-worked'),
      :'age' => DataStore.get('age'),
      :'commute-distances' => DataStore.get('commute-distances'),
      :'children-per-employee' => DataStore.get('children-per-employee')
    }
  end
end
