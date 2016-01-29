class Crystal < Thor
  desc "gender SAV_FILE GENDER", "Change player's gender"
  def gender(file, gender)
    offset = 0x3E3D
    case gender
    when 'male'
      IO.binwrite file, "\x00", offset
    when 'female'
      IO.binwrite file, "\x01", offset
    else
      abort "Gender must be one of 'male' or 'female'"
    end
  end
end
