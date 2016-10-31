class ControllrController < ApplicationController
  def show
    render json: {
      :'employees' => DataStore.get('employees'),
      :'contractors' => DataStore.get('contractors'),
      :'salary-performance' => DataStore.get('salary-performance'),
      :'hours-worked' => DataStore.get('hours-worked'),
      :'salary-graph' => DataStore.get('salary-graph'),
      :'average-age' => DataStore.get('average-age'),
      :'commute-distances' => DataStore.get('commute-distances'),
      :'children-per-employee' => DataStore.get('children-per-employee')
    }
  end
end
