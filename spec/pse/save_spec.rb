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
