require 'spec_helper'
require 'mongo/jira/commands'

describe Mongo::Jira::Commands do

  subject { Mongo::Jira::Commands.new}

  describe 'conf file exists' do
    it 'must return false if no agreement' do
      Mongo::Jira::Config.expects(:check).returns(true)
      subject.expects(:agree).returns(false)
      Mongo::Jira::Config.expects(:save).never
      assert_equal subject.init('filename'),false
    end

    it 'must return true if agreement' do
      Mongo::Jira::Config.expects(:check).returns(true)
      subject.expects(:agree).returns(true)
      subject.stubs(:prompt)
      subject.stubs(:ask)
      Mongo::Jira::Config.stubs(:save)
      assert_equal subject.init('filename'), true
    end

    describe :config do

      def do_setup(password='password123')

        Mongo::Jira::Config.stubs(:check).returns(true)
        subject.stubs(:agree).returns(true)

        #subject.stubs(:prompt)
        #subject.stubs(:ask)
        subject.expects(:prompt).with('username', anything).returns('username123')
        subject.expects(:ask).with("password (<%= color('hit ENTER for none', :password) %>) ? ").returns(password)
        subject.expects(:prompt).with('site', anything).returns('site123')
        subject.expects(:prompt).with('auth_type', anything).returns('auth_type123')
      end

      it 'must setup config if agreement' do
        do_setup()
        Mongo::Jira::Config.expects(:save).with(anything, 'filename')
        subject.init('filename')
      end

      it 'must setup config if agreement' do
        do_setup()
        Mongo::Jira::Config.expects(:save).with(has_entry(:username , 'username123'), anything)
        subject.init('filename')
      end

      it 'must setup config if agreement' do
        do_setup()
        Mongo::Jira::Config.expects(:save).with(has_entry(:site , 'site123'), anything)
        subject.init('filename')
      end

      it 'must setup config if agreement' do
        do_setup()
        Mongo::Jira::Config.expects(:save).with(has_entry(:password , 'password123'), anything)
        subject.init('filename')
      end


      it 'must setup config if agreement' do
        do_setup()
        Mongo::Jira::Config.expects(:save).with(has_entry(:auth_type , 'auth_type123'), anything)
        subject.init('filename')
      end

      it 'must remove empty passwords' do
        do_setup('   ')
        Mongo::Jira::Config.expects(:save).with(Not(has_key(:password)), 'filename')
        subject.init('filename')
      end
    end


    it 'must save config to file' do
      subject.stubs(:prompt)
      subject.stubs(:ask)

      Mongo::Jira::Config.expects(:check).returns(true)
      subject.expects(:agree).returns(true)
      Mongo::Jira::Config.expects(:save).with(anything,'filename')
      subject.init('filename')
    end
  end

end