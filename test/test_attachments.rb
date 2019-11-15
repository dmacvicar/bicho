# frozen_string_literal: true

require_relative 'helper'
require 'digest'

# Test for bug attachments
class AttachmentsTest < Minitest::Test
  def test_client_get_attachments
    VCR.use_cassette('bugzilla.gnome.org_679745_attachments') do
      Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

      attachments = Bicho.client.get_attachments(679745)
      assert_kind_of(Array, attachments)
      assert !attachments.empty?

      attachments.each do |attachment|
        assert_kind_of(Bicho::Attachment, attachment)

        next unless attachment.id == 329690
        assert_equal('text/plain', attachment.content_type)
        assert_equal(8559, attachment.size)
        assert_equal('user-accounts: use Password Login instead of Automatic Login',
                     attachment.summary)

        assert_equal('80c4665205bcbd2b90ea920eff21f29988d8fc85f36c293a65fa3dad52d19354',
                     Digest::SHA256.hexdigest(attachment.data.read))
      end
    end
  end

  def teardown
    Bicho.client = nil
  end
end
