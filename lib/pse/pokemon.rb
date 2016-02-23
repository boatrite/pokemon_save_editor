class PSE::Pokemon

  attr_accessor :bytes, :nickname_bytes, :ot_name_bytes

  def initialize(bytes, nickname_bytes, ot_name_bytes)
    @bytes = bytes
    @nickname_bytes = nickname_bytes
    @ot_name_bytes = ot_name_bytes
  end

  def species
    PSE::HEX_TO_POKEMON.fetch bytes[0]
  end

  def held_item
    if bytes[1].zero?
      nil
    else
      PSE::HEX_TO_ITEM.fetch bytes[1]
    end
  end

  def moves
    bytes[2..5].map { |byte|
      if byte.zero?
        nil
      else
        PSE::HEX_TO_MOVE.fetch byte
      end
    }
  end

  def ot_trainer_id
    bytes_to_integer bytes[6..7]
  end

  def experience
    bytes_to_integer bytes[8..10]
  end

  def hp_evs
    bytes_to_integer bytes[11..12]
  end

  def attack_evs
    bytes_to_integer bytes[13..14]
  end

  def defense_evs
    bytes_to_integer bytes[15..16]
  end

  def speed_evs
    bytes_to_integer bytes[17..18]
  end

  def special_evs
    bytes_to_integer bytes[19..20]
  end

  # Returns of the form ['00000000', '00000000'].
  def ivs
    # 4 bits per IV.
    # There is no separate value for HP.
    # Instead, it is a combination of the others.
    bytes[21..22].flat_map { |byte|
      binary_string = byte.to_s(2)
      [
        binary_string[0..3],
        binary_string[4..7]
      ]
    }.map { |binary_string|
      binary_string.to_i(2)
    }
  end

  def attack_iv
    ivs[0]
  end

  def defense_iv
    ivs[1]
  end

  def speed_iv
    ivs[2]
  end

  def special_iv
    ivs[3]
  end

  def hp_iv
    # Take first bit of the 4 other IVs
    # to get the HP IV.
    ivs
      .map { |iv| iv.to_s(2)[-1] }
      .reduce(:+)
      .to_i(2)
  end

  def move_pps
    # For each byte,
    # the first 2 bits are for applied PP Ups,
    # the last 6 bits for current PP.
    bytes[23..26]
      .map { |byte| "%08b" % byte }
      .map { |binary_string|
        [
          binary_string[0..1].to_i(2),
          binary_string[2..7].to_i(2)
        ]
      }
  end

  def first_move_pp_ups
    move_pps[0].first
  end

  def first_move_current_pp
    move_pps[0].last
  end

  def second_move_pp_ups
    move_pps[1].first
  end

  def second_move_current_pp
    move_pps[1].last
  end

  def third_move_pp_ups
    move_pps[2].first
  end

  def third_move_current_pp
    move_pps[2].last
  end

  def fourth_move_pp_ups
    move_pps[3].first
  end

  def fourth_move_current_pp
    move_pps[3].last
  end

  def friendship
    bytes_to_integer [bytes[27]]
  end

  # Returns an binary string with 8 bits.
  def pokerus
    "%08b" % bytes[28]
  end

  def pokerus_strain
    # The first 4 bits are the strain
    pokerus[0..3]
  end

  def pokerus_days_remaining
    # The last 4 bits are the days remaining.
    pokerus[4..7].to_i(2)
  end

  def caught_data
    bytes[29..30]
  end

  def caught_time_and_level
    "%08b" % caught_data.first
  end

  def caught_time
    PSE::HEX_TO_TIME_OF_DAY.fetch caught_time_and_level[0..1].to_i(2)
  end

  def caught_level
    caught_time_and_level[2..7].to_i(2)
  end

  def ot_gender_and_location
    "%08b" % caught_data.last
  end

  def ot_gender
    ot_gender = PSE::HEX_TO_GENDER.fetch ot_gender_and_location[0].to_i
  end

  def caught_location
    PSE::HEX_TO_LOCATION.fetch ot_gender_and_location[1..7].to_i(2)
  end

  def current_level
    bytes[31]
  end

  def ot_name
    # TODO Refactor this into some sort of parse_name method?
    # This logic is similar to the ot_name method in Pokemon,
    # and the player_name/rival_name methods in Save.
    name_padding_bytes = [0x50]
    ot_name_bytes[0..6]
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHAR.fetch byte }
      .join
  end

  def nickname
    # TODO Refactor this into some sort of parse_name method?
    # This logic is similar to the ot_name method in Pokemon,
    # and the player_name/rival_name methods in Save.
    name_padding_bytes = [0x50]
    nickname_bytes
      .reject { |byte| name_padding_bytes.include? byte }
      .map { |byte| PSE::HEX_TO_CHAR.fetch byte }
      .join
  end

  def as_json
    {
      nickname: nickname,
      species: species,
      held_item: held_item,
      moves: moves,
      experience: experience,

      hp_evs: hp_evs,
      attack_evs: attack_evs,
      defense_evs: defense_evs,
      speed_evs: speed_evs,
      special_evs: special_evs,

      hp_iv: hp_iv,
      attack_iv: attack_iv,
      defense_iv: defense_iv,
      speed_iv: speed_iv,
      special_iv: special_iv,

      first_move_pp_ups: first_move_pp_ups,
      first_move_current_pp: first_move_current_pp,
      second_move_pp_ups: second_move_pp_ups,
      second_move_current_pp: second_move_current_pp,
      third_move_pp_ups: third_move_pp_ups,
      third_move_current_pp: third_move_current_pp,
      fourth_move_pp_ups: fourth_move_pp_ups,
      fourth_move_current_pp: fourth_move_current_pp,

      friendship: friendship,

      pokerus_strain: pokerus_strain,
      pokerus_days_remaining: pokerus_days_remaining,

      caught_time: caught_time,
      caught_level: caught_level,
      caught_location: caught_location,

      ot_trainer_id: ot_trainer_id,
      ot_name: ot_name,
      ot_gender: ot_gender,

      current_level: current_level
    }
  end

  private

  # TODO Move this to a module of some sort since it is used in Pokemon and Save
  # Or maybe to the refinement
  def bytes_to_integer(bytes)
    # bytes are big endian, so we need to reverse the bytes array
    # so that lower index corresponds with lower significant byte.
    bytes.reverse.each_with_index.reduce(0) do |integer, (byte, index)|
      integer += byte * 2**(8*index)
    end
  end
end
