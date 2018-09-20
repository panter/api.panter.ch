require 'open_api'

OpenApi::Config.tap do |c|
  c.file_output_path = 'public'
  # without this it will try to use `ApplicationRecord` as the base class,
  # which does not exist in this project (since we're not using ActiveRecord).
  c.active_record_base = BasicObject

  c.open_api_docs = {
    api: {
      base_doc_class: ApplicationController,
      info: {
        title: 'Panter API',
        description: 'All publicly available data of the company Panter AG',
        version: '1.0.0'
      }
    }
  }
end
