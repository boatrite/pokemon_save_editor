using HexExtensions

RSpec.describe HexExtensions do

  describe Fixnum do
    describe '#to_hex_s' do
      it 'returns Fixnum as nicely formatted hex number' do
        expect(0x42.to_hex_s).to eq '0x42'
        expect(80.to_hex_s).to eq '0x50'
      end
    end
  end

  describe String do
    describe '#to_hex_s' do
      it 'returns String as nicely formatted hex number' do
        expect("\x42".to_hex_s).to eq '0x42'
        expect("\x99\x29\x80\xFA".to_hex_s).to eq '0x99 0x29 0x80 0xFA'
      end
    end
  end
end
