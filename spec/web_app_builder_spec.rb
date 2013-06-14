require 'web_app_builder'

describe WebAppBuilder do

  let(:basedir) { File.expand_path("#{File.dirname(__FILE__)}/..") }

  subject { WebAppBuilder.new("#{basedir}/build", basedir, "web_app_builder") }

  before do
    subject.clean
    subject.prepare
  end

  it "should create new zip file with files at particular folder" do
    subject.war
  end

  it "should create new exploded directory with files" do
    subject.war_exploded
  end

end
