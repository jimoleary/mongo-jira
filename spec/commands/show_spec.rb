require 'spec_helper'
require 'mongo/jira/commands'

describe Mongo::Jira::Commands do

  subject { Mongo::Jira::Commands.new}

  before do
    @ticket= mock('ticket')
    Mongo::Jira::Model::Ticket.stubs(:new).returns(@ticket)

    @one= mock('one') do
      stubs(:key).returns 'one'
    end

    @two= mock('two') do
      stubs(:key).returns 'two'
    end
    @three= mock('three') do
      stubs(:key).returns 'three'
    end

    @client= mock('client')
    #do
    #  stubs(:find).with('one').returns @one
    #  stubs(:find).with('two').returns @tow
    #  stubs(:find).with('three').returns @three
    #
    #end
    subject.stubs(:debug)
    subject.stubs(:say)
    subject.stubs(:render)
    subject.stubs(:client).returns(@client)
  end

  it 'must handle no projects' do
    assert_equal [], subject.show([],{})
  end

  describe 'find' do
    it 'must handle one' do
      @client.expects(:find).with('one')
      subject.show(%w(one),{})
    end
    it 'must handle one two' do
      @client.expects(:find).with('one')
      @client.expects(:find).with('two')
      subject.show(%w{one two},{})
    end
    it 'must handle one  three' do
      @client.expects(:find).with('one')
      @client.expects(:find).with('three')
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
    end
    it 'must handle one' do
      subject.stubs(:limit).returns([@one])
      assert_equal [@one], subject.show(%w(one),{})
    end
    it 'must handle one two' do
      subject.stubs(:limit).returns([@one, @two])
      assert_equal [@one, @two], subject.show(%w{one two},{})
    end
    it 'must handle one  three' do
      subject.stubs(:limit).returns([@one, @three])
      assert_equal [@one, @three], subject.show(%w{one three},{})
    end
    it 'must pass tickets' do
      subject.stubs(:limit).with([@one, @three],anything).returns([@one, @three])
      assert_equal [@one, @three], subject.show(%w{one three},{})
    end
    it 'must pass limit' do
      subject.stubs(:limit).with(anything, :value).returns([@one, @three])
      assert_equal [@one, @three], subject.show(%w{one three},{:limit=>:value})
    end
  end

  describe 'render' do

    it 'must not be called for no projects' do
      subject.stubs(:limit).returns([])
      subject.expects(:render).never
      subject.show(%w{},{})
    end

    it 'must render reverse ' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.expects(:render).with(anything,has_entry(:reverse=>:value))
      subject.show(%w{},{:reverse=>:value})
    end
    it 'must render as' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.expects(:render).with(anything,has_entry(:as=>:value))
      subject.show(%w{},{:as=>:value})
    end
    it 'must render list ' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.expects(:new).with(@one).returns(:one)
      subject.expects(:render).with(:one,anything)
      subject.show(%w{},{})
    end
    it 'must say ' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.stubs(:new).with(@one).returns(:one)
      subject.stubs(:render).returns(:render)
      subject.expects(:say).with(:render)
      subject.show(%w{},{})
    end
    it 'must render list ' do
      subject.stubs(:limit).returns([@one, @two])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.expects(:new).with(@one).returns(:one)
      Mongo::Jira::Model::Ticket.expects(:new).with(@two).returns(:two)
      subject.expects(:render).with(:one,anything)
      subject.expects(:render).with(:two,anything)
      subject.show(%w{},{})
    end
    it 'must say ' do
      subject.stubs(:limit).returns([@one,@two])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.stubs(:render).returns(:render)
      subject.expects(:say).times(2)
      subject.show(%w{},{})
    end

    it 'must return ticket' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:render)
      subject.stubs(:say)
      assert_equal [@one], subject.show(%w{},{})
    end

  end

end