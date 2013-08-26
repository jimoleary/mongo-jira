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

  it 'must handle no projects' do
    assert_equal [], subject.open([],{})
  end

  describe 'find' do
    it 'must handle one' do
      @client.expects(:find).with('one')
      subject.stubs(:limit).returns([])
      subject.open(%w(one),{})
    end
    it 'must handle one two' do
      @client.expects(:find).with('one').returns(@one)
      @client.expects(:find).with('two').returns(@two)
      subject.stubs(:limit).returns([])
      subject.open(%w{one two},{})
    end
    it 'must handle one  three' do
      @client.expects(:find).with('one')
      @client.expects(:find).with('three')
      subject.stubs(:limit).returns([])
      subject.show(%w{one three},{})
    end
    it 'must handle two three' do
      @client.expects(:find).with('two')
      @client.expects(:find).with('three')
      subject.show(%w{two three},{})
    end
  end
  describe 'limit' do
    before do
      @client.stubs(:find).with('one').returns(@one)
      @client.stubs(:find).with('two').returns(@two)
      @client.stubs(:find).with('three').returns(@three)
      @one.stubs(:attrs).returns {}
      @two.stubs(:attrs).returns {}
      @three.stubs(:attrs).returns {}

      subject.stubs(:`)
    end
    it 'must handle one' do
      subject.stubs(:limit).returns([@one])
      @one.stubs(:attrs).returns({})
      assert_equal [@one], subject.open(%w(one),{})
    end
    it 'must handle one two' do
      subject.stubs(:limit).returns([@one, @two])
      @one.stubs(:attrs).returns({})
      @two.stubs(:attrs).returns({})
      assert_equal [@one, @two], subject.open(%w{one two},{})
    end
    it 'must handle one  three' do
      subject.stubs(:limit).returns([@one, @three])
      @one.stubs(:attrs).returns({})
      @three.stubs(:attrs).returns({})
      assert_equal [@one, @three], subject.open(%w{one three},{})
    end
    it 'must pass tickets' do
      subject.stubs(:limit).with([@one, @three],anything).returns([@one, @three])
      @one.stubs(:attrs).returns({})
      @three.stubs(:attrs).returns({})
      assert_equal [@one, @three], subject.open(%w{one three},{})
    end
    it 'must pass limit' do
      subject.stubs(:limit).with(anything, :value).returns([@one, @three])
      @one.stubs(:attrs).returns({})
      @three.stubs(:attrs).returns({})
      assert_equal [@one, @three], subject.open(%w{one three},{:limit=>:value})
    end
  end
  describe 'open' do
    before do
      @client.stubs(:find).with('one').returns(@one)
      @client.stubs(:find).with('two').returns(@two)
      @client.stubs(:find).with('three').returns(@three)
    end
    it 'must handle one' do
      subject.stubs(:limit).returns([@one])
      @one.stubs(:attrs).returns({})
      @one.stubs(:key).returns('KEY')
      subject.expects(:`).with("open 'https://jira.mongodb.org/browse/KEY'")

      subject.open(%w(one),{})
    end
    it 'must handle one two' do
      subject.stubs(:limit).returns([@one, @two])
      @one.stubs(:attrs).returns({})
      @two.stubs(:attrs).returns({})
      @one.stubs(:key).returns('ONE')
      @two.stubs(:key).returns('TWO')
      subject.expects(:`).with("open 'https://jira.mongodb.org/browse/ONE'")
      subject.expects(:`).with("open 'https://jira.mongodb.org/browse/TWO'")
      subject.open(%w{one two},{})
    end
  end

  describe 'render' do
    it 'must return ticket' do
      @one.stubs(:attrs).returns({})
      subject.stubs(:limit).returns([@one])
      subject.stubs(:render)
      subject.stubs(:say)
      subject.stubs(:`)
      assert_equal [@one], subject.open(%w{},{})
    end

  end

end