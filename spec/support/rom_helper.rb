RSpec.configure do |config|
  config.before :each do
    FileUtils.cp 'rom/Crystal.sav', 'spec/fixtures/Crystal.sav'
  end

  config.after :each do
    FileUtils.rm 'spec/fixtures/Crystal.sav'
  end
end
