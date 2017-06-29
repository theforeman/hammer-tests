class Hash

  def slice(*keys)
    Hash[select { |k, v| keys.include?(k) }]
  end

  def to_opts
    opts = []
    self.collect do |key, value|
      opts << "--#{key.to_s.gsub('_', '-')}"
      opts << "#{value}"
    end
    opts
  end
end
