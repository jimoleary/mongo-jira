require 'spec_helper'
require 'mongo/jira/commands'

describe Mongo::Jira::Commands do

  subject { Mongo::Jira::Commands.new}

  before do
    @view = mock('view') do
      stubs(:options=)
      stubs(:debug)
      stubs(:render)
    end
    subject.stubs(:debug)
    @gem_path = [Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view']
  end

  describe 'absolute paths' do
    it 'must be correct for /' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/'}

      @view.expects('options=').with(has_entry(:loc, %w(/ terminal)))
      @view.expects(:render).with(:ticket,'ticket')
      subject.render(:ticket,o)
    end
    it 'must be correct for single custom path' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/custom'}

      @view.expects('options=').with(has_entry(:loc, %w(/ )))
      @view.expects(:render).with(:ticket,'custom')
      subject.render(:ticket,o)
    end
    it 'must be correct for 2 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/first/second'}

      @view.expects('options=').with(has_entry(:loc, %w(/first)))
      @view.expects(:render).with(:ticket,'second')
      subject.render(:ticket,o)
    end
    it 'must be correct for 3 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/first/second/third'}

      @view.expects('options=').with(has_entry(:loc, %w(/first/second)))
      @view.expects(:render).with(:ticket,'third')
      subject.render(:ticket,o)
    end

    it 'must be correct for 4 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/first/second/third/fourth'}

      @view.expects('options=').with(has_entry(:loc, %w(/first/second/third)))
      @view.expects(:render).with(:ticket,'fourth')
      subject.render(:ticket,o)
    end

  end
  describe 'relative paths' do
    it 'must be correct for .' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '.'}

      @view.expects('options=').with(has_entry(:loc, %w(. terminal)))
      @view.expects(:render).with(:ticket,'ticket')
      subject.render(:ticket,o)
    end
    it 'must be correct for single custom path' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> './custom'}

      @view.expects('options=').with(has_entry(:loc, %w(. )))
      @view.expects(:render).with(:ticket,'custom')
      subject.render(:ticket,o)
    end
    it 'must be correct for 2 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> './first/second'}

      @view.expects('options=').with(has_entry(:loc, %w(./first)))
      @view.expects(:render).with(:ticket,'second')
      subject.render(:ticket,o)
    end
    it 'must be correct for 3 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> './first/second/third'}

      @view.expects('options=').with(has_entry(:loc, %w(./first/second)))
      @view.expects(:render).with(:ticket,'third')
      subject.render(:ticket,o)
    end

    it 'must be correct for 4 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> '/first/second/third/fourth'}

      @view.expects('options=').with(has_entry(:loc, %w(/first/second/third)))
      @view.expects(:render).with(:ticket,'fourth')
      subject.render(:ticket,o)
    end

  end
  describe 'gem paths' do
    it 'must handle missing key' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {}

      @view.expects('options=').with(has_entry(:loc, @gem_path  + %w(terminal)))
      @view.expects(:render).with(:ticket,'ticket')
      subject.render(:ticket,o)
    end
    it 'must handle nil value' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> nil}

      @view.expects('options=').with(has_entry(:loc, @gem_path  + %w(terminal)))
      @view.expects(:render).with(:ticket,'ticket')
      subject.render(:ticket,o)
    end
    it 'must handle blank value' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> ''}

      @view.expects('options=').with(has_entry(:loc, @gem_path  + %w(terminal)))
      @view.expects(:render).with(:ticket,'ticket')
      subject.render(:ticket,o)
    end
    it 'must be correct for first' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> 'first'}

      @view.expects('options=').with(has_entry(:loc, @gem_path  + %w(terminal)))
      @view.expects(:render).with(:ticket,'first')
      subject.render(:ticket,o)
    end
    it 'must be correct for single custom path' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> 'custom'}

      @view.expects('options=').with(has_entry(:loc,  @gem_path  + %w(terminal)))
      @view.expects(:render).with(:ticket,'custom')
      subject.render(:ticket,o)
    end
    it 'must be correct for 2 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> 'first/second'}

      @view.expects('options=').with(has_entry(:loc,  @gem_path  + %w(first)))
      @view.expects(:render).with(:ticket,'second')
      subject.render(:ticket,o)
    end
    it 'must be correct for 3 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> 'first/second/third'}

      @view.expects('options=').with(has_entry(:loc, @gem_path  +  %w(first/second)))
      @view.expects(:render).with(:ticket,'third')
      subject.render(:ticket,o)
    end

    it 'must be correct for 4 custom' do
      Mongo::Jira::Render::View.stubs(:new).returns(@view)
      o = {:as=> 'first/second/third/fourth'}

      @view.expects('options=').with(has_entry(:loc, @gem_path  +   %w(first/second/third)))
      @view.expects(:render).with(:ticket,'fourth')
      subject.render(:ticket,o)
    end

  end
end