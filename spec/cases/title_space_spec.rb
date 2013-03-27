require 'spec_helper'
describe "Mobi book file generator" do

  after :all do
    puts '==== clear tmp files ==='
    #`rm -rf ./__*`
  end

  it "should generate books given title contains space" do
    title = 'title with space'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>'<img src="http://images.fanpop.com/images/image_uploads/widescreen-season-4-wallpaper-lost-661159_1680_1050.jpg"/>this is the page 3',:wrap=>true
    book.generate
    book.should be_generated
  end
end
