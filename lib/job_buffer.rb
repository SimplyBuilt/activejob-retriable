module JobBuffer
  def self.clear
    values.clear
  end

  def self.add(value)
    values << value
  end

  def self.values
    @values ||= []
  end
end
