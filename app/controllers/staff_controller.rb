class StaffController < ApiController
  def attributes
    [
      :'employees',
      :'contractors',
      :'hours-worked',
      :'age',
      :'commute-distances',
      :'children-per-employee',
    ]
  end
end
