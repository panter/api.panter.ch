class CodeController < ApiController
  def attributes
    [
      :commits,
      :pullRequestComments,
      :lineAdditions,
      :lineDeletions,
      :programmingLanguages,
      :frameworks
    ]
  end

  api :show, 'GET code' do
    desc 'The code endpoint returns data related to development.'

    response :success, '', :json, data: {
      commits!: {
        count!: { type: Integer, example: '4' }
      },
      pullRequestComments!: {
        count!: { type: Integer, example: '2' }
      },
      lineAdditions!: {
        count!: { type: Integer, example: '32' }
      },
      lineDeletions!: {
        count!: { type: Integer, example: '20' }
      },
      programmingLanguages!: [{
        name!: { type: String, example: 'JavaScript' },
        percentage!: { type: Float, example: 36.86 },
      }],
      frameworks!: [{
        name!: { type: String, example: 'Rails' },
        percentage!: { type: Float, example: 37.87 },
      }]
    }
  end
end
