
require 'spec_helper'
describe "Mobi book file generator" do

  after :all do
    puts '==== clear tmp files ==='
    #`rm -rf ./__*`
  end

  it "should have the title,author property" do
    title = 'simple-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true,:mobi_type => :simple
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page4',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.title.should == title
    book.author.should == author
    book.generate
    book.should be_generated
  end
end
