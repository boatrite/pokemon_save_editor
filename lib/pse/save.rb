class PSE::Save
  attr_accessor :path

  module Gender
    BOY = "\x00"
    GIRL = "\x01"
  end

  def initialize(path)
    @path = path
  end

  def gender
    IO.binread path, PSE::Datum::GENDER.length, PSE::Datum::GENDER.offset
  end

  def gender=(gender)
    # TODO Put in check that it is valid
    IO.binwrite path, gender, PSE::Datum::GENDER.offset
  end

  def player_name
    IO.binread path, PSE::Datum::PLAYER_NAME.length, PSE::Datum::PLAYER_NAME.offset
  end

  def player_name=(new_player_name)
    # TODO Put in check that it is 7 characters or less
    bytes = new_player_name.chars.map { |char| PSE::CHARS.fetch char }
    # Crystal reserves 11 bytes for the name, but only 7 of these are usable.
    # The first 8 bytes contain the name with any leftover equal to 0x50.
    # Since the name can be 7 bytes at most, there will be at least one 0x50 of padding.
    # The remaining 3 bytes are equal to 0x00.
    padding = [0x50] * (8 - bytes.length) + [0x00] * 3
    bytes += padding
    # Each array element is a signed 8-bit, so we use 'c' to pack them.
    byte_string = bytes.pack('c*')
    IO.binwrite path, byte_string, PSE::Datum::PLAYER_NAME.offset
    update_checksum
  end

  def checksum_1
    IO.binread path, PSE::Datum::CHECKSUM1.length, PSE::Datum::CHECKSUM1.offset
  end

  def checksum_2
    IO.binread path, PSE::Datum::CHECKSUM2.length, PSE::Datum::CHECKSUM2.offset
  end

  private

  def calculate_checksum_1
    start_1 = 0x2009
    end_1 = 0x2b82
    len_1 = end_1 - start_1
    byte_string = IO.read path, len_1, start_1
    calculate_checksum byte_string
  end

  def calculate_checksum_2
    start_2 = 0x1209
    end_2 = 0x1d82
    len_2 = end_2 - start_2
    byte_string = IO.read path, len_2, start_2
    calculate_checksum byte_string
  end

  def calculate_checksum(byte_string)
    sum = byte_string.bytes.reduce(:+)
    [sum].pack('s')
  end

  # This is sufficient for the game to use the modified data.
  def update_checksum_1
    IO.binwrite path, calculate_checksum_1, PSE::Datum::CHECKSUM1.offset
  end
  alias_method :update_checksum, :update_checksum_1
end
