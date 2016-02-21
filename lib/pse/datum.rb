module PSE::Datum
  Offset = Struct.new('Offset', :length, :offset)

  GENDER = Offset.new 1, 0x3e3d
  PLAYER_NAME = Offset.new 11, 0x200b
  CHECKSUM = Offset.new 2, 0x2d0d
end
