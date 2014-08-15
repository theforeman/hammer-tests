class Hash

  def slice(*keys)
    Hash[select { |k, v| keys.include?(k) }]
  end

end
