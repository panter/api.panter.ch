class GitController < ApplicationController
  def show
    render json: {
      :'commits' => DataStore.get('commits'),
      :'pull-request-comments' => DataStore.get('pull-request-comments'),
      :'additions-deletions' => DataStore.get('additions-deletions'),
      :'programming-languages' => DataStore.get('programming-languages'),
      :'frameworks' => DataStore.get('frameworks')
    }
  end
end
