module HexExtensions
  refine Fixnum do
    def to_hex_s
      "0x#{"%02X" % self}"
    end
  end

  refine String do
    def to_hex_s
      bytes.map { |b| b.to_hex_s }.join ' '
    end
  end
end
