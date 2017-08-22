require_relative 'helper'

BUG_ES_EXPORT=<<-EOF
{
  "priority": "Normal",
  "blocks": [

  ],
  "creator": "kekun.plazas@laposte.net",
  "last_change_time": "2017-02-22 20:48:43 UTC",
  "is_cc_accessible": true,
  "keywords": [

  ],
  "cc": [
    "kekun.plazas@laposte.net",
    "mcatanzaro@gnome.org"
  ],
  "url": "",
  "assigned_to": "gnome-games-maint@gnome.bugs",
  "see_also": [

  ],
  "groups": [

  ],
  "id": 777777,
  "creation_time": "2017-01-26 08:46:00 UTC",
  "whiteboard": "",
  "qa_contact": "gnome-games-maint@gnome.bugs",
  "depends_on": [

  ],
  "resolution": "FIXED",
  "classification": "Core",
  "op_sys": "Linux",
  "status": "RESOLVED",
  "cf_gnome_target": "---",
  "cf_gnome_version": "---",
  "summary": "Game Boy games not detected",
  "is_open": false,
  "platform": "Other",
  "severity": "normal",
  "flags": [

  ],
  "version": "unspecified",
  "component": "general",
  "is_creator_accessible": true,
  "product": "gnome-games",
  "is_confirmed": true,
  "target_milestone": "---",
  "history": [
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 09:03:10 UTC",
      "changes": [
        {
          "removed": "",
          "added": "kekun.plazas@laposte.net",
          "field_name": "cc"
        }
      ]
    },
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 09:05:34 UTC",
      "changes": [
        {
          "attachment_id": 344292,
          "removed": "0",
          "added": "1",
          "field_name": "attachments.isobsolete"
        }
      ]
    },
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 09:06:09 UTC",
      "changes": [
        {
          "removed": "NEW",
          "added": "RESOLVED",
          "field_name": "status"
        },
        {
          "removed": "",
          "added": "FIXED",
          "field_name": "resolution"
        }
      ]
    },
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 09:06:13 UTC",
      "changes": [
        {
          "attachment_id": 344293,
          "removed": "none",
          "added": "committed",
          "field_name": "attachments.gnome_attachment_status"
        }
      ]
    },
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 09:06:16 UTC",
      "changes": [
        {
          "attachment_id": 344294,
          "removed": "none",
          "added": "committed",
          "field_name": "attachments.gnome_attachment_status"
        }
      ]
    },
    {
      "who": "kekun.plazas@laposte.net",
      "timestamp": "2017-01-26 11:06:35 UTC",
      "changes": [
        {
          "attachment_id": 344303,
          "removed": "none",
          "added": "committed",
          "field_name": "attachments.gnome_attachment_status"
        }
      ]
    },
    {
      "who": "mcatanzaro@gnome.org",
      "timestamp": "2017-02-22 20:40:19 UTC",
      "changes": [
        {
          "removed": "",
          "added": "mcatanzaro@gnome.org",
          "field_name": "cc"
        }
      ]
    }
  ],
  "resolution_time": "2017-01-26 09:06:09 UTC"
}
EOF

# Test small utilities
class ExportTest < Minitest::Test
  def test_to_json
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')
    bug = Bicho.client.get_bug(777777)
    assert_equal(
      JSON.dump(JSON.load(BUG_ES_EXPORT)),
      Bicho::Export.to_json(bug)
    )
  end
end
