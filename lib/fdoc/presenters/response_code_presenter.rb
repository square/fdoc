class Fdoc::ResponseCodePresenter < Fdoc::HTMLPresenter
  def response_code
    presented
  end

  def status
    response_code["status"]
  end

  def description
    response_code["description"]
  end
end
