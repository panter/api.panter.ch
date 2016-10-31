class ApiController < ApplicationController
  def show
    json = attributes.map do |attribute|
      [attribute, DataStore.get(attribute)]
    end.to_h

    render json: json
  end

  private

  # @virtual
  def attributes
    []
  end
end
