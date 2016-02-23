class PSE::Save
  using HexExtensions

  attr_accessor :path

  # TODO Remove this module now that PSE::HEX_TO_GENDER and its inverse exist
  module Gender
    BOY = "\x00"
    GIRL = "\x01"
  end
  GENDERS = Gender.constants.map &Gender.method(:const_get)

  # TODO Create HEX_TO_PALETTE and inverse like all the other HEX_TO_*
  module Palette
    RED = "\x00"
    BLUE = "\x01"
    GREEN = "\x02"
    BROWN = "\x03"
    ORANGE = "\x04"
    GRAY = "\x05"
    DARK_GREEN = "\x06"
    DARK_RED = "\x07"
  end
  PALETTES = Palette.constants.map &Palette.method(:const_get)

  def initialize(path)
    @path = path
  end

  def trainer_id
    byte_string = read PSE::Datum::TRAINER_ID.length, PSE::Datum::TRAINER_ID.offset
    bytes = byte_string.bytes
    bytes_to_integer bytes
  end

  def trainer_id=(new_trainer_id)
    if new_trainer_id < 0 || new_trainer_id > 2**16-1
      raise ArgumentError.new "Trainer ID must be between 00000 and 65535"
    end
    byte_string = integer_to_bytes(new_trainer_id, PSE::Datum::TRAINER_ID.length).pack 'c*'
    write byte_string, PSE::Datum::TRAINER_ID.offset
    update_checksum
  end

  def player_name
    # TODO Refactor this into some sort of parse_name method?
    # This logic is similar to the ot_name method in Pokemon,
    # and the player_name/rival_name methods in Save.
    name_padding_bytes = [0x50]
    byte_string = read PSE::Datum::PLAYER_NAME.length, PSE::Datum::PLAYER_NAME.offset
    byte_string
      .bytes[0..6]
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHAR.fetch byte }
      .join
  end

  def player_name=(new_player_name)
    validate_name new_player_name
    bytes = new_player_name.chars.map { |char| PSE::CHAR_TO_HEX.fetch char }
    # Crystal reserves 11 bytes for the name, but only 7 of these are usable.
    # The first 8 bytes contain the name with any leftover equal to 0x50.
    # Since the name can be 7 bytes at most, there will be at least one 0x50 of padding.
    # The remaining 3 bytes are equal to 0x00.
    padding = [0x50] * (PSE::Datum::PLAYER_NAME.length - 3 - bytes.length) + [0x00, 0x00, 0x00]
    bytes += padding
    # Each array element is a signed 8-bit, so we use 'c' to pack them.
    byte_string = bytes.pack('c*')
    write byte_string, PSE::Datum::PLAYER_NAME.offset
    update_checksum
  end

  def rival_name
    # TODO Refactor this into some sort of parse_name method?
    # This logic is similar to the ot_name method in Pokemon,
    # and the player_name/rival_name methods in Save.
    name_padding_bytes = [0x50]
    byte_string = read PSE::Datum::RIVAL_NAME.length, PSE::Datum::RIVAL_NAME.offset
    byte_string
      .bytes[0..6]
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHAR.fetch byte }
      .join
  end

  def rival_name=(new_rival_name)
    validate_name new_rival_name
    bytes = new_rival_name.chars.map { |char| PSE::CHAR_TO_HEX.fetch char }
    # Crystal reserves 11 bytes for the name, but only 7 of these are usable.
    # The first 8 bytes contain the name with any leftover equal to 0x50.
    # Since the name can be 7 bytes at most, there will be at least one 0x50 of padding.
    # The remaining 3 bytes are equal to 0x86, 0x91, 0x84 respectively.
    padding = [0x50] * (PSE::Datum::RIVAL_NAME.length - 3 - bytes.length) + [0x86, 0x91, 0x84]
    bytes += padding
    # Each array element is a signed 8-bit, so we use 'c' to pack them.
    byte_string = bytes.pack('c*')
    write byte_string, PSE::Datum::RIVAL_NAME.offset
    update_checksum
  end

  def gender
    read PSE::Datum::GENDER.length, PSE::Datum::GENDER.offset
  end

  def gender=(new_gender)
    unless GENDERS.include? new_gender
      raise ArgumentError.new "Invalid gender. Given #{new_gender.to_hex_s} but must be one of #{GENDERS.map { |g| g.to_hex_s }}"
    end
    write new_gender, PSE::Datum::GENDER.offset
  end

  def palette
    read PSE::Datum::PALETTE.length, PSE::Datum::PALETTE.offset
  end

  def palette=(new_palette)
    unless PALETTES.include? new_palette
      raise ArgumentError.new "Invalid palette. Given #{new_palette.to_hex_s} but must be one of #{PALETTES.map { |p| p.to_hex_s }}"
    end
    write new_palette, PSE::Datum::PALETTE.offset
    update_checksum
  end

  def money
    byte_string = read PSE::Datum::MONEY.length, PSE::Datum::MONEY.offset
    bytes = byte_string.bytes
    bytes_to_integer bytes
  end

  def money=(new_money)
    if new_money < 0 || new_money > 999999
      raise ArgumentError.new "Money must be between 0 and 999,999"
    end
    byte_string = integer_to_bytes(new_money, PSE::Datum::MONEY.length).pack 'c*'
    write byte_string, PSE::Datum::MONEY.offset
    update_checksum
  end

  def tms
    byte_string = read PSE::Datum::POCKET_TMS.length, PSE::Datum::POCKET_TMS.offset
    byte_string.bytes.each_with_object({}).with_index do |(count, tms), index|
      tms["TM #{(index + 1).to_s.rjust(2, '0')}"] = count
    end
  end

  def max_tms
    # 0x63 = 99
    new_byte_string = (["\x63"] * PSE::Datum::POCKET_TMS.length).join
    write new_byte_string, PSE::Datum::POCKET_TMS.offset
    update_checksum
  end

  def hms
    byte_string = read PSE::Datum::POCKET_HMS.length, PSE::Datum::POCKET_HMS.offset
    byte_string.bytes.each_with_object({}).with_index do |(count, hms), index|
      hms["HM #{(index + 1).to_s.rjust(2, '0')}"] = count
    end
  end

  def max_hms
    new_byte_string = (["\x01"] * PSE::Datum::POCKET_HMS.length).join
    write new_byte_string, PSE::Datum::POCKET_HMS.offset
    update_checksum
  end

  def items
    byte_string = read PSE::Datum::POCKET_ITEMS.length, PSE::Datum::POCKET_ITEMS.offset
    bytes = byte_string.bytes
    count = bytes.shift
    bytes = bytes.reject { |b| b == 0xFF || b == 0x00 }
    if bytes.length % 2 != 0
      raise "Have an odd number of entries in item bytes array.\nI don't think this should happen.\nbyte_string: #{byte_string}\nbytes: #{bytes}"
    end
    bytes.each_slice(2).each_with_object({}) do |(item, count), items|
      item_name = PSE::HEX_TO_ITEM.fetch item
      items[item_name] = count
    end
  end

  def items=(new_items)
    count = new_items.count
    if count > 20
      raise ArgumentError.new "Cannot have more than 20 items"
    end
    new_bytes = [count]
    new_bytes += new_items.each_with_object([]) do |(item_name, item_count), new_entry_bytes|
      if item_count < 1 || item_count > 99
        raise ArgumentError.new "Item count for #{item_name} must be between 1 and 99"
      end
      if (item = PSE::ITEM_TO_HEX[item_name]).nil?
        raise ArgumentError.new "Item doesn't exist: #{item_name}"
      end
      new_entry_bytes << item
      new_entry_bytes << item_count
    end
    new_bytes << 0xFF
    new_byte_string = new_bytes.pack('c*')
    write new_byte_string, PSE::Datum::POCKET_ITEMS.offset
    update_checksum
  end

  def pokemon_team
    byte_string = read PSE::Datum::POKEMON_TEAM.length, PSE::Datum::POKEMON_TEAM.offset
    bytes = byte_string.bytes
    count = bytes.shift
    team_species_ids = bytes.shift 6
    team_species_id_terminator = bytes.shift
    all_pokemon_data = 6.times.each_with_object([]) { |i, all_pokemon_data| all_pokemon_data[i] = bytes.shift 48 }
    ot_names = 6.times.each_with_object([]) { |i, ot_names| ot_names[i] = bytes.shift 11 }
    nicknames = 6.times.each_with_object([]) { |i, nicknames| nicknames[i] = bytes.shift 11 }
    6.times.each_with_object([]) do |i, pokemon_team|
      pokemon_data = all_pokemon_data[i]

      if pokemon_data.uniq == [0] # This means that there is no pokemon in this slot, so we skip it
        pokemon_team << nil
        next
      end

      pokemon = PSE::Pokemon.new pokemon_data, nicknames[i], ot_names[i]
      pokemon_team << pokemon.as_json
    end
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

  def validate_name(name)
    if name.strip.empty?
      raise ArgumentError.new "Invalid name. Cannot be blank"
    end
    if name.length > 7
      raise ArgumentError.new "Invalid name. Cannot be longer than 7 characters"
    end
    name.chars.each { |char|
      unless PSE::CHAR_TO_HEX.include? char
        raise ArgumentError.new "Invalid name. Invalid character: #{char}"
      end
    }
  end

  # TODO Move this to a module of some sort since it is used in Pokemon and Save
  # Or maybe to the refinement
  def bytes_to_integer(bytes)
    # bytes are big endian, so we need to reverse the bytes array
    # so that lower index corresponds with lower significant byte.
    bytes.reverse.each_with_index.reduce(0) do |integer, (byte, index)|
      integer += byte * 2**(8*index)
    end
  end

  def integer_to_bytes(integer, length)
    (0...length).reverse_each.each_with_object([]) do |power_multiple, bytes|
      byte, integer = integer.divmod 2**(8*power_multiple)
      bytes << byte
    end
  end
end
