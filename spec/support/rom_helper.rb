RSpec.configure do |config|
  # Make sure all of our tests use the same sav file.
  config.before :each do
    FileUtils.cp 'spec/fixtures/Crystal.original.sav', 'spec/fixtures/Crystal.sav'
  end

  # When all tests are done, reset the sav file to the original.
  config.after :all do
    FileUtils.cp 'spec/fixtures/Crystal.original.sav', 'spec/fixtures/Crystal.sav'
  end
end
