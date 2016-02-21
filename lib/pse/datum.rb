module PSE::Datum
  Offset = Struct.new('Offset', :length, :offset)

  CHECKSUM = Offset.new 2, 0x2d0d
  GENDER = Offset.new 1, 0x3e3d
  MONEY = Offset.new 3, 0x23dc
  PLAYER_NAME = Offset.new 11, 0x200b
  RIVAL_NAME = Offset.new 11, 0x2021
end
