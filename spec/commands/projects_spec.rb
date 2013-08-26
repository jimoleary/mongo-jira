require 'spec_helper'
require 'mongo/jira/commands'

describe Mongo::Jira::Commands do

  subject { Mongo::Jira::Commands.new}

  before do
    @client= mock('client')
    @one= mock('one') do
      stubs(:key).returns 'one'
    end

    @two= mock('two') do
      stubs(:key).returns 'two'
    end
    @three= mock('three') do
      stubs(:key).returns 'three'
    end
    subject.stubs(:debug)
    subject.stubs(:say)
    subject.stubs(:render)
    subject.stubs(:client).returns(@client)
    @gem_path = [Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view']
  end

  it 'must handle no projects' do
    @client.stubs(:projects).returns([])
    assert_equal [], subject.projects('',{})
  end

  describe 'globs' do
    it 'must handle *' do
      @client.stubs(:projects).returns([@one, @two ,@three])
      assert_equal [@one, @two ,@three], subject.projects(%w{*},{})
    end
    it 'must handle one' do
      @client.stubs(:projects).returns([@one, @two ,@three])
      assert_equal [@one], subject.projects(%w{*one*},{})
    end
    it 'must handle one three' do
      @client.stubs(:projects).returns([@one, @two ,@three])
      assert_equal [@one, @three], subject.projects(%w{*one* *three*},{})
    end
    it 'must handle two three' do
      @client.stubs(:projects).returns([@one, @two ,@three])
      assert_equal [@two, @three], subject.projects(%w{*two* *three*},{})
    end
  end

  describe 'limit' do
    before do
      @client.stubs(:projects).returns([@one, @two ,@three])
    end

    it 'must be called' do
      subject.expects(:limit).returns([@one, @two ,@three])
      subject.projects(%w{*},{})
    end

    it 'must pass on projects' do
      subject.expects(:limit).with([@one, @two ,@three],anything).returns([])
      subject.projects(%w{*},{})
    end

    it 'must pass on nil limits' do
      subject.expects(:limit).with(anything, nil).returns([])
      subject.projects(%w{*},{})
    end

    it 'must pass on limits' do
      subject.expects(:limit).with(anything, :value).returns([])
      subject.projects(%w{*},{:limit => :value})
    end
  end
  describe 'render' do
    before do
      @client.stubs(:projects).returns([])
      subject.stubs(:say)
    end

    it 'must not be called for no projects' do
      subject.stubs(:limit).returns([])
      subject.expects(:render).never
      subject.projects(%w{*},{})
    end

    it 'must render list ' do
      subject.stubs(:limit).returns([@one])
      subject.expects(:render).with([@one],anything,anything)
      subject.projects(%w{*},{})
    end

    it 'must render reverse' do
      subject.stubs(:limit).returns([@one])
      subject.expects(:render).with(anything,has_entry(:reverse, :value),anything)
      subject.projects(%w{*},{:reverse => :value})
    end

    it 'must render as' do
      subject.stubs(:limit).returns([@one])
      subject.expects(:render).with(anything,has_entry(:as, :value),anything)
      subject.projects(%w{*},{:as => :value})
    end

    it 'must render default as' do
      subject.stubs(:limit).returns([@one])
      subject.expects(:render).with(anything,has_entry(:as, :project),anything)
      subject.projects(%w{*},{})
    end

    it 'must skip say' do
      subject.stubs(:limit).returns([])
      subject.expects(:say).never
      subject.projects(%w{*},{})
    end

    it 'must say' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:render)
      subject.expects(:say)
      subject.projects(%w{*},{})
    end

    it 'must say return of render' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:render).returns(:value)
      subject.expects(:say).with(:value)
      subject.projects(%w{*},{})
    end

    it 'must return projects' do
      subject.stubs(:limit).returns([@one])
      subject.stubs(:render)
      subject.stubs(:say)
      assert_equal [@one], subject.projects(%w{*},{})
    end

  end

end