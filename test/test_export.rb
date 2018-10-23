require_relative 'helper'

# Test small utilities
class ExportTest < Minitest::Test
  def test_to_json
    VCR.use_cassette('bugzilla.gnome.org_777777_export') do
      Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')
      bug = Bicho.client.get_bug(777777)
      File.write('777777.json', Bicho::Export.to_json(bug))

      assert_equal(
        JSON.dump(JSON.load(File.read(fixture('777777.json')))),
        Bicho::Export.to_json(bug)
      )
    end
  end
end
