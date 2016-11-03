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
end
