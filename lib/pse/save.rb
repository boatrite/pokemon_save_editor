class PSE::Save
  using HexExtensions

  attr_accessor :path

  module Gender
    BOY = "\x00"
    GIRL = "\x01"
  end
  GENDERS = Gender.constants.map &Gender.method(:const_get)

  def initialize(path)
    @path = path
  end

  def gender
    IO.binread path, PSE::Datum::GENDER.length, PSE::Datum::GENDER.offset
  end

  def gender=(gender)
    unless GENDERS.include? gender
      raise ArgumentError.new "Invalid gender. Given #{gender.to_hex_s} but must be one of #{GENDERS.map { |g| g.to_hex_s }}"
    end
    IO.binwrite path, gender, PSE::Datum::GENDER.offset
  end

  def player_name
    name_padding_bytes = [0x50, 0x00]
    byte_string = IO.binread path, PSE::Datum::PLAYER_NAME.length, PSE::Datum::PLAYER_NAME.offset
    byte_string
      .bytes
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHARS.fetch byte }
      .join
  end

  def player_name=(new_player_name)
    if new_player_name.strip.empty?
      raise ArgumentError.new "Invalid name. Cannot be blank"
    end
    if new_player_name.length > 7
      raise ArgumentError.new "Invalid name. Cannot be longer than 7 characters"
    end
    bytes = new_player_name.chars.map { |char|
      unless PSE::CHARS_TO_HEX.include? char
        raise ArgumentError.new "Invalid name. Invalid character: #{char}"
      end
      PSE::CHARS_TO_HEX.fetch char
    }
    # Crystal reserves 11 bytes for the name, but only 7 of these are usable.
    # The first 8 bytes contain the name with any leftover equal to 0x50.
    # Since the name can be 7 bytes at most, there will be at least one 0x50 of padding.
    # The remaining 3 bytes are equal to 0x00.
    zero_padding_length = 3
    padding = [0x50] * (PSE::Datum::PLAYER_NAME.length - zero_padding_length - bytes.length) + [0x00] * zero_padding_length
    bytes += padding
    # Each array element is a signed 8-bit, so we use 'c' to pack them.
    byte_string = bytes.pack('c*')
    IO.binwrite path, byte_string, PSE::Datum::PLAYER_NAME.offset
    update_checksum
  end

  def current_checksum
    IO.binread path, PSE::Datum::CHECKSUM.length, PSE::Datum::CHECKSUM.offset
  end

  def calculate_checksum
    block_start = 0x2009
    block_end = 0x2b82
    block_length = block_end - block_start
    byte_string = IO.read path, block_length, block_start
    sum = byte_string.bytes.reduce(:+)
    [sum].pack('s')
  end

  def update_checksum
    # This is sufficient for the game to use the modified data.
    IO.binwrite path, calculate_checksum, PSE::Datum::CHECKSUM.offset
  end
end
