class ErrorSerializer
  def initialize(error_object)
    @error_object = error_object
  end

  def serialize_json
    {
      errors: [
        {
          status: @error_object.status_code.to_s,
          title: @error_object.message
        }
      ]
    }
  end

  def data_serialize 
    {data: @error_object}
  end
end