RSpec.describe Save do
  let(:save) { Save.new 'spec/fixtures/Crystal.sav' }

  describe '#trainer_id' do
    it "returns the player's trainer ID" do
      expect(save.trainer_id).to eq 36426
    end
  end

  describe '#trainer_id=' do
    it "sets the player's trainer ID" do
      expect {
        save.trainer_id = 12345
      }.to change { save.trainer_id }.from(36426).to 12345
    end

    it 'raises an error if the given ID is not between 00000 and 65535' do
      expect {
        save.trainer_id = -1
      }.to raise_error ArgumentError, 'Trainer ID must be between 00000 and 65535'
      expect {
        save.trainer_id = 655536
      }.to raise_error ArgumentError, 'Trainer ID must be between 00000 and 65535'
    end
  end

  describe '#player_name' do
    it "returns the player's name" do
      expect(save.player_name).to eq 'Amelia'
    end
  end

  describe '#player_name=' do
    it "sets the player's name" do
      expect {
        save.player_name = 'Rory'
      }.to change { save.player_name }.from('Amelia').to 'Rory'
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.player_name = 'Rory'
    end

    it 'raises an error if the name is blank' do
      expect {
        save.player_name = ''
      }.to raise_error 'Invalid name. Cannot be blank'
      expect {
        save.player_name = '    '
      }.to raise_error 'Invalid name. Cannot be blank'
    end

    it 'raises an error if the name is longer than 7 characters' do
      expect {
        save.player_name = 'The Doctor'
      }.to raise_error 'Invalid name. Cannot be longer than 7 characters'
    end

    it 'raises an error if an invalid character is given' do
      expect {
        save.player_name = 'ジ'
      }.to raise_error 'Invalid name. Invalid character: ジ'
    end
  end

  describe '#rival_name' do
    it "returns the rival's name" do
      expect(save.rival_name).to eq 'Silver'
    end
  end

  describe '#rival_name=' do
    it "sets the rival's name" do
      expect {
        save.rival_name = 'SILVER'
      }.to change { save.rival_name }.from('Silver').to 'SILVER'
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.rival_name = 'SILVER'
    end

    it 'raises an error if the name is blank' do
      expect {
        save.rival_name = ''
      }.to raise_error 'Invalid name. Cannot be blank'
      expect {
        save.rival_name = '    '
      }.to raise_error 'Invalid name. Cannot be blank'
    end

    it 'raises an error if the name is longer than 7 characters' do
      expect {
        save.rival_name = 'The Master'
      }.to raise_error 'Invalid name. Cannot be longer than 7 characters'
    end

    it 'raises an error if an invalid character is given' do
      expect {
        save.rival_name = 'ジ'
      }.to raise_error 'Invalid name. Invalid character: ジ'
    end
  end

  describe '#gender' do
    it "returns the player's gender" do
      expect(save.gender).to eq "\x01"
    end
  end

  describe '#gender=' do
    it "sets the player's gender" do
      expect {
        save.gender = Save::Gender::BOY
      }.to change { save.gender }.from("\x01").to "\x00"
    end

    it 'raises an error if an invalid byte is given' do
      expect {
        save.gender = "\x42"
      }.to raise_error ArgumentError, 'Invalid gender. Given 0x42 but must be one of ["0x00", "0x01"]'
    end
  end

  describe '#palette' do
    it 'returns the palette' do
      expect(save.palette).to eq Save::Palette::BLUE
    end
  end

  describe '#palette=' do
    it "sets the player's palette" do
      expect {
        save.palette = Save::Palette::RED
      }.to change { save.palette }.from("\x01").to "\x00"
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.palette = Save::Palette::RED
    end

    it 'raises an error if an invalid byte is given' do
      expect {
        save.palette = "\x42"
      }.to raise_error ArgumentError, 'Invalid palette. Given 0x42 but must be one of ["0x00", "0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07"]'
    end
  end

  describe '#money' do
    it 'returns the amount of money the player has' do
      expect(save.money).to eq 3300
    end
  end

  describe '#money=' do
    it 'sets the amount of money the player has' do
      expect {
        save.money = 999999
      }.to change { save.money }.from(3300).to 999999
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.money = 999999
    end

    it 'raises an error if the given number is not between 0 and 999,999' do
      expect {
        save.money = -1
      }.to raise_error ArgumentError, "Money must be between 0 and 999,999"
      expect {
        save.money = 1000000
      }.to raise_error ArgumentError, "Money must be between 0 and 999,999"
    end
  end

  describe '#tms' do
    it 'returns the current TMs' do
      expect(save.tms).to eq({
        "TM 01" => 0, "TM 02" => 0, "TM 03" => 0, "TM 04" => 0, "TM 05" => 0, "TM 06" => 0, "TM 07" => 0, "TM 08" => 0, "TM 09" => 0, "TM 10" => 0,
        "TM 11" => 0, "TM 12" => 0, "TM 13" => 0, "TM 14" => 0, "TM 15" => 0, "TM 16" => 0, "TM 17" => 0, "TM 18" => 0, "TM 19" => 0, "TM 20" => 0,
        "TM 21" => 0, "TM 22" => 0, "TM 23" => 0, "TM 24" => 0, "TM 25" => 0, "TM 26" => 0, "TM 27" => 0, "TM 28" => 0, "TM 29" => 0, "TM 30" => 0,
        "TM 31" => 0, "TM 32" => 0, "TM 33" => 0, "TM 34" => 0, "TM 35" => 0, "TM 36" => 0, "TM 37" => 0, "TM 38" => 0, "TM 39" => 0, "TM 40" => 0,
        "TM 41" => 0, "TM 42" => 0, "TM 43" => 0, "TM 44" => 0, "TM 45" => 0, "TM 46" => 0, "TM 47" => 0, "TM 48" => 0, "TM 49" => 0, "TM 50" => 0
      })
    end
  end

  describe '#max_tms' do
    it 'maxes the TM counts' do
      expect {
        save.max_tms
      }.to change { save.tms }.to({
        "TM 01" => 99, "TM 02" => 99, "TM 03" => 99, "TM 04" => 99, "TM 05" => 99, "TM 06" => 99, "TM 07" => 99, "TM 08" => 99, "TM 09" => 99, "TM 10" => 99,
        "TM 11" => 99, "TM 12" => 99, "TM 13" => 99, "TM 14" => 99, "TM 15" => 99, "TM 16" => 99, "TM 17" => 99, "TM 18" => 99, "TM 19" => 99, "TM 20" => 99,
        "TM 21" => 99, "TM 22" => 99, "TM 23" => 99, "TM 24" => 99, "TM 25" => 99, "TM 26" => 99, "TM 27" => 99, "TM 28" => 99, "TM 29" => 99, "TM 30" => 99,
        "TM 31" => 99, "TM 32" => 99, "TM 33" => 99, "TM 34" => 99, "TM 35" => 99, "TM 36" => 99, "TM 37" => 99, "TM 38" => 99, "TM 39" => 99, "TM 40" => 99,
        "TM 41" => 99, "TM 42" => 99, "TM 43" => 99, "TM 44" => 99, "TM 45" => 99, "TM 46" => 99, "TM 47" => 99, "TM 48" => 99, "TM 49" => 99, "TM 50" => 99
      })
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.max_tms
    end
  end

  describe '#hms' do
    it 'returns the current HMs' do
      expect(save.hms).to eq({
        "HM 01" => 0, "HM 02" => 0, "HM 03" => 0, "HM 04" => 0, "HM 05" => 0, "HM 06" => 0, "HM 07" => 0
      })
    end
  end

  describe '#max_hms' do
    it 'maxes the HM counts' do
      expect {
        save.max_hms
      }.to change { save.hms }.to({
        "HM 01" => 1, "HM 02" => 1, "HM 03" => 1, "HM 04" => 1, "HM 05" => 1, "HM 06" => 1, "HM 07" => 1
      })
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.max_tms
    end
  end

  describe '#items' do
    it 'returns the current items' do
      expect(save.items).to eq({
        'Potion' => 2,
        'Berry' => 3,
        'Antidote' => 1
      })
    end
  end

  describe '#items=' do
    let(:new_items) {{
      'Full Restore' => 99, 'Rare Candy' => 99, 'Sacred Ash' => 99, 'Max Revive' => 99,
      'Gold Berry' => 99, 'Max Repel' => 99, 'Escape Rope' => 99,'Nugget' => 99,
      'PP Up' => 99, 'HP Up' => 99, 'Protein' => 99, 'Iron' => 99, 'Carbos' => 99, 'Calcium' => 99,
      'Moon Stone' => 99, 'Fire Stone' => 99, 'Thunder Stone' => 99, 'Water Stone' => 99, 'Leaf Stone' => 99, 'Sun Stone' => 99
    }}

    it 'sets the items the player has' do
      expect {
        save.items = new_items
      }.to change { save.items }.to new_items
    end

    it 'updates the checksum' do
      expect(save).to receive :update_checksum
      save.items = new_items
    end

    it "raises an error if a given item can't be found" do
      new_items.delete 'Full Restore'
      expect {
        save.items = new_items.merge 'Foobar' => 99
      }.to raise_error ArgumentError, "Item doesn't exist: Foobar"
    end

    it "raises an error if the count isn't between 0 and 99" do
      expect {
        save.items = new_items.merge 'Full Restore' => 100
      }.to raise_error ArgumentError, "Item count for Full Restore must be between 1 and 99"
      expect {
        save.items = new_items.merge 'Full Restore' => 0
      }.to raise_error ArgumentError, "Item count for Full Restore must be between 1 and 99"
    end

    it 'raises an error if more than 20 items are given' do
      expect {
        save.items = new_items.merge 'Max Elixer' => 99
      }.to raise_error ArgumentError, "Cannot have more than 20 items"
    end
  end

  describe '#pokemon_team' do
    it 'returns the current pokemon team' do
      # TODO Give held item so that gets tested.
      # TODO Confirm that the IVs are assigned to the correct stat.
      expect(save.pokemon_team).to eq [
        {
          nickname: "SPIKE",
          species: "Totodile",
          held_item: nil,
          moves: ["Scratch", "Leer", "Rage", nil],
          experience: 659,

          hp_evs: 830,
          attack_evs: 730,
          defense_evs: 754,
          speed_evs: 982,
          special_evs: 604,

          hp_iv: 7,
          attack_iv: 12,
          defense_iv: 3,
          speed_iv: 13,
          special_iv: 1,

          first_move_pp_ups: 0,
          first_move_current_pp: 33,
          second_move_pp_ups: 0,
          second_move_current_pp: 30,
          third_move_pp_ups: 0,
          third_move_current_pp: 20,
          fourth_move_pp_ups: 0,
          fourth_move_current_pp: 0,

          friendship: 96,

          pokerus_strain: "0000",
          pokerus_days_remaining: 0,

          caught_time: "Morning",
          caught_level: 5,
          caught_location: "New Bark Town",

          ot_trainer_id: 36426,
          ot_name: "Amelia",
          ot_gender: "Girl",

          current_level: 10,
        },
        nil,
        nil,
        nil,
        nil,
        nil
      ]
    end
  end

  describe '#current_checksum' do
    it 'returns the currently saved checksum for the primary copy of data' do
      expect(save.current_checksum).to eq "\x96\xFA".force_encoding(Encoding::ASCII_8BIT)
    end
  end

  describe '#calculate_checksum' do
    it 'calculates and returns the checksum for the primary copy of data' do
      expect {
        save.player_name = 'Doctor'
      }.to change { save.calculate_checksum }
        .from("\x96\xFA".force_encoding(Encoding::ASCII_8BIT))
        .to("\xB8\xFA".force_encoding(Encoding::ASCII_8BIT))
    end
  end

  describe '#update_checksum' do
    it 'updates the currently saved checksum' do
      allow(save).to receive(:calculate_checksum).and_return "\x42\x42"
      expect {
        save.update_checksum
      }.to change { save.current_checksum }
        .from("\x96\xFA".force_encoding(Encoding::ASCII_8BIT))
        .to("\x42\x42".force_encoding(Encoding::ASCII_8BIT))
    end
  end
end
