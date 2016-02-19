module CrystalSaveEditor
  class Reader
    GENDER = [0x3E3D, 1]
    attr_reader :sav, :sav_filename

    def initialize(sav_filename)
      @sav_filename = sav_filename
      @sav = File.binread sav_filename
    end

    def read
    end
  end
end
