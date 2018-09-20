desc 'Generates the API Documentation'
task doc: :environment do
  OpenApi.write_docs
end
