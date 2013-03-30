require 'spec_helper'
describe "Mobi book file generator" do

  after :all do
    puts '==== clear tmp files ==='
    #`rm -rf ./__*`
  end

  it "should generate books given title contains space" do
    title = 'title with space nice'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true, :mobi_type => 'simple'
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>'<img src="http://images.fanpop.com/images/image_uploads/Anne-Hathaway-anne-hathaway-749084_1280_800.jpg"/>this is the page 3',:wrap=>true
    book.generate
    book.should be_generated
  end
end
