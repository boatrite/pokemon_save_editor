require 'spec_helper'

RSpec.describe CrystalSaveEditor::Reader do
  describe '#read' do
    it 'works' do
      reader = CrystalSaveEditor::Reader.new 'spec/fixtures/Crystal.sav'
      reader.read
    end
  end
end
