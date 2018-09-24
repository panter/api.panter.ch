class ApiController < ApplicationController
  include OpenApi::DSL

  def show
    json = attributes.map do |attribute, datastore_attribute = attribute|
      [attribute, DataStore.get(datastore_attribute)]
    end.to_h

    render json: json
  end

  private

  # @virtual
  def attributes
    []
  end
end
