module CrystalSaveEditor
  class Reader
    attr_reader :sav, :sav_filename

    def initialize(sav_filename)
      @sav_filename = sav_filename
      @sav = File.binread sav_filename
    end

    def read
      require 'pry'; binding.pry
    end
  end
end
