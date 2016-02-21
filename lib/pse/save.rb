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
    read PSE::Datum::GENDER.length, PSE::Datum::GENDER.offset
  end

  def gender=(gender)
    unless GENDERS.include? gender
      raise ArgumentError.new "Invalid gender. Given #{gender.to_hex_s} but must be one of #{GENDERS.map { |g| g.to_hex_s }}"
    end
    write gender, PSE::Datum::GENDER.offset
  end

  def player_name
    name_padding_bytes = [0x50]
    byte_string = read PSE::Datum::PLAYER_NAME.length, PSE::Datum::PLAYER_NAME.offset
    byte_string
      .bytes[0..6]
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
    write byte_string, PSE::Datum::PLAYER_NAME.offset
    update_checksum
  end

  def rival_name
    name_padding_bytes = [0x50]
    byte_string = read PSE::Datum::RIVAL_NAME.length, PSE::Datum::RIVAL_NAME.offset
    byte_string
      .bytes[0..6]
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHARS.fetch byte }
      .join
  end

  def money
    byte_string = read PSE::Datum::MONEY.length, PSE::Datum::MONEY.offset
    bytes = byte_string.bytes
    # The first byte is the number of multiples of 2^16 (65536)
    # The second byte is the number of multiples of 2^8 (256)
    # The third byte is the number of multiples of 2^0 (1)
    [bytes[0] * 2**16, bytes[1] * 2**8, bytes[2]].reduce(:+)
  end

  def money=(new_money)
    if new_money < 0 || new_money > 999999
      raise ArgumentError.new "Money must be between 0 and 999,999"
    end
    first_byte, remainder = new_money.divmod 2**16
    second_byte, third_byte = remainder.divmod 2**8
    byte_string = [first_byte, second_byte, third_byte].pack 'c*'
    write byte_string, PSE::Datum::MONEY.offset
    update_checksum
  end

  def current_checksum
    read PSE::Datum::CHECKSUM.length, PSE::Datum::CHECKSUM.offset
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
    write calculate_checksum, PSE::Datum::CHECKSUM.offset
  end

  def test
    require 'pry'; binding.pry
  end

  private

  def read(length, offset)
    IO.binread path, length, offset
  end

  def write(byte_string, offset)
    IO.binwrite path, byte_string, offset
  end
end
