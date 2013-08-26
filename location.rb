module Location
  attr :street_address, :zip

  def initialize(address, zip)
    @street_address=address
    @zip=zip
  end

  def street_address 
    return @street_address
  end
  def zip
    return @zip
  end
end

        
