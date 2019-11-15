# frozen_string_literal: true

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

  def test_to_prometheus
    VCR.use_cassette('bugzilla.gnome.org_search_prometheus_export') do
      Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')
      query = Bicho::Query.new.product('vala').product('gnome-terminal').open
      export = Bicho::Export.to_prometheus_push_gateway(query)
      assert_equal(
        File.read(fixture('bugzilla_gnome_org_search_prometheus_export.txt')),
        export
      )
    end
  end
end
