module PSE
  HEX_TO_GENDER = {
    0x00 => 'Boy',
    0x01 => 'Girl'
  }

  GENDER_TO_HEX = HEX_TO_GENDER.invert
end
