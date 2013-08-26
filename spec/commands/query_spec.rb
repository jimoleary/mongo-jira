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
    @client.stubs(:jql).returns([])
    assert_equal [], subject.query([],{})
  end

  it 'must call client jql' do
    @client.expects(:jql).returns([])
    subject.query(%W(one two three),{})
  end

  it 'must call client jql with join params' do
    @client.expects(:jql).with('one two three').returns([])
    subject.query(%W(one two three),{})
  end

  describe 'limit' do
    before do
      @client.stubs(:jql).returns([:all])
    end
    it 'must call limit' do
      subject.expects(:limit).returns([])
      subject.query(%w(),{})
    end
    it 'must call limit with tickets' do
      subject.expects(:limit).with([:all],anything).returns([])
      subject.query(%w(),{})
    end
    it 'must call limit with limit' do
      subject.expects(:limit).with(anything, :value).returns([])
      subject.query(%w(),{:limit => :value})
    end
  end
  describe 'render' do
    before do
      @client.stubs(:jql).returns([:all])
      subject.stubs(:say)
    end

    it 'must not be called for no ticket' do
      subject.stubs(:limit).returns([])
      subject.expects(:render).never
      subject.query(%w{},{})
    end

    it 'must render reverse ' do
      subject.stubs(:limit).returns([@one])
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.expects(:render).with(anything,has_entry(:reverse=>:value))
      subject.query(%w{},{:reverse=>:value})
    end

    it 'must render as' do
      subject.stubs(:limit).returns([@one])
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.expects(:render).with(anything,has_entry(:as=>:value))
      subject.query(%w{},{:as=>:value})
    end

    it 'must render list ' do
      subject.stubs(:limit).returns([@one])
      Mongo::Jira::Model::Ticket.expects(:new).with(@one).returns(:one)
      subject.expects(:render).with(:one,anything)
      subject.query(%w{},{})
    end
    it 'must say ' do
      subject.stubs(:limit).returns([@one])
      Mongo::Jira::Model::Ticket.stubs(:new).with(@one).returns(:one)
      subject.stubs(:render).returns(:render)
      subject.expects(:say).with(:render)
      subject.query(%w{},{})
    end
    it 'must render list ' do
      subject.stubs(:limit).returns([@one, @two])
      Mongo::Jira::Model::Ticket.expects(:new).with(@one).returns(:one)
      Mongo::Jira::Model::Ticket.expects(:new).with(@two).returns(:two)
      subject.expects(:render).with(:one,anything)
      subject.expects(:render).with(:two,anything)
      subject.query(%w{},{})
    end
    it 'must say list' do
      subject.stubs(:limit).returns([@one,@two])
      subject.stubs(:say)
      Mongo::Jira::Model::Ticket.stubs(:new)
      subject.stubs(:render).returns(:render)
      subject.expects(:say).times(2)
      subject.query(%w{},{})
    end


  end

  describe 'render' do
    it 'must return ticket' do
      subject.stubs(:limit).returns([@one])
      @client.stubs(:jql)
      subject.stubs(:say)
      assert_equal [@one], subject.query(%w{},{})
    end

  end

end