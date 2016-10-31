class CodeController < ApiController
  def attributes
    [
      :'commits',
      :'pull-request-comments',
      :'line-additions',
      :'line-deletions',
      :'programming-languages',
      :'frameworks'
    ]
  end
end
