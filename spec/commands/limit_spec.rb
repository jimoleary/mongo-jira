require 'spec_helper'
require 'mongo/jira/commands'

describe Mongo::Jira::Commands do

  subject { Mongo::Jira::Commands.new}

  before do
    @ticket= mock('ticket')
    Mongo::Jira::Model::Ticket.stubs(:new).returns(@ticket)

    @one= mock('one') do
      stubs(:key).returns 'one'
      stubs(:attrs).returns {}
    end

    @two= mock('two') do
      stubs(:key).returns 'two'
      stubs(:attrs).returns {}
    end
    @three= mock('three') do
      stubs(:key).returns 'three'
      stubs(:attrs).returns {}
    end

    @client= mock('client')
    subject.stubs(:debug)
    subject.stubs(:trace)
    subject.stubs(:say)
    subject.stubs(:render)
    subject.stubs(:client).returns(@client)
  end

  it 'must handle nil tickets' do
    assert_equal nil, subject.limit(nil)
  end

  it 'must handle no tickets' do
    assert_equal [], subject.limit([])
  end

  it 'must handle uncompacted tickets' do
    assert_equal [], subject.limit([nil])
  end

  it 'must handle no limit' do
    assert_equal %w(one two three), subject.limit(%w(one two three))
  end

  it 'must flatten tickets' do
    assert_equal %w(one two three), subject.limit([%w(one two three)],3)
  end

  it 'must compact tickets' do
    assert_equal %w(one two three), subject.limit([nil, ['one', nil, 'two', 'three'], nil],3)
  end

  it 'must handle 0 limit' do
    assert_equal %w(one), subject.limit(%w(one two three),0 )
  end

  it 'must handle negative limit' do
    assert_equal %w(one), subject.limit(%w(one two three),-1 )
  end

  it 'must limit list to single item' do
    assert_equal %w(one), subject.limit(%w(one two three),1 )
  end

  it 'must limit list to 2 items ' do
    assert_equal %w(one two), subject.limit(%w(one two three),2 )
  end

  it 'must limit list to greater then list ' do
    assert_equal %w(one two three), subject.limit(%w(one two three),4 )
  end

end