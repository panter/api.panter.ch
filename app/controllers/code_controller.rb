class CodeController < ApplicationController
  def show
    render json: {
      :'commits' => DataStore.get('commits'),
      :'pull-request-comments' => DataStore.get('pull-request-comments'),
      :'line-additions' => DataStore.get('line-additions'),
      :'line-deletions' => DataStore.get('line-deletions'),
      :'programming-languages' => DataStore.get('programming-languages'),
      :'frameworks' => DataStore.get('frameworks')
    }
  end
end
