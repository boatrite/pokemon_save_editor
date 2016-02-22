module PSE::Datum
  Offset = Struct.new('Offset', :length, :offset)

  CHECKSUM = Offset.new 2, 0x2D0D
  GENDER = Offset.new 1, 0x3E3D
  MONEY = Offset.new 3, 0x23DC
  PALETTE = Offset.new 1, 0x206A
  PLAYER_NAME = Offset.new 11, 0x200B
  RIVAL_NAME = Offset.new 11, 0x2021
  TRAINER_ID = Offset.new 2, 0x2009
end
