require_relative 'helper'

# Test query DSL
class QueryTest < Minitest::Test
  def setup
    Bicho.client = nil
  end

  def test_active_record_style
    # No client set yet
    assert_raises RuntimeError do
      Bicho::Bug.where.assigned_to('foo@bar.com').each do |bug|
        puts bug
      end
    end

    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

    ret = Bicho::Bug.where.product('vala').status('resolved').component('Basic Types').each.to_a
    assert ret.collect(&:id).include?(645_150)
  end

  def test_query_addition_of_attributes
    ret = Bicho::Query.new.status('foo').status('bar')
    assert_equal({ 'status' => %w(foo bar) }, ret.query_map)
  end

  def test_query_shortcuts
    ret = Bicho::Query.new.open
    assert_equal({ 'status' => [:new, :assigned, :needinfo, :reopened, :confirmed, :in_progress] }, ret.query_map)
  end

  def teardown
    Bicho.client = nil
  end
end
