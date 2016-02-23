module PSE
  HEX_TO_TIME_OF_DAY = {
    0x01 => 'Morning',
    0x02 => 'Day',
    0x03 => 'Night'
  }

  TIME_OF_DAY_TO_HEX = HEX_TO_TIME_OF_DAY.invert
end
