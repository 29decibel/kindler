require 'spec_helper'
describe "Mobi book file generator" do

  after :all do
    puts '==== clear tmp files ==='
    #`rm -rf ./__*`
  end

  it "should have the title,author property" do
    title = 'first-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true
    book.title.should == title
    book.author.should == author
  end

  it "should have the generated dir contains book infos" do
    title = 'first-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true
    book.generate
    book.should be_generated
  end

  it "should contains the contents.html and ncx file" do
    title = 'first-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    File.should be_exist("./#{Kindler::Book::TMP_DIR_PREFIX}#{title}/contents.html")
    File.should be_exist("./#{Kindler::Book::TMP_DIR_PREFIX}#{title}/nav-contents.ncx")
  end

  it "contents file should include the page" do
    title = 'first-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.generate
    contents = File.open("./#{Kindler::Book::TMP_DIR_PREFIX}#{title}/contents.html").readlines
    contents.count.should > 0
    contents.select {|a| a.include?("001.html")}.count.should > 0
    book.should be_generated
  end

  it "should not generate a mobi book" do
    title = 'good_book'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>'this is the page 3',:wrap=>true
    book.generate
    book.should be_generated
  end

  it "should generate book contains images" do
    title = 'book_with_image'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>'<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"/>this is the page 3',:wrap=>true
    book.generate
    book.should be_generated
    File.should be_exist("./#{Kindler::Book::TMP_DIR_PREFIX}#{title}/1.jpg")
  end

  it "can access pages information before generate" do
    title = 'test_contents'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'love page1',:author=>'mike1',:content=>'this is the love page1',:section => 'love'
    book.add_page :title=>'love page2',:author=>'mike1',:content=>'this is the love page2',:section => 'love'
    book.add_page :title=>'hate page1',:author=>'mike1',:content=>'this is the hate page1',:section => 'hate'
    book.add_page :title=>'love page3',:author=>'mike1',:content=>'this is the love page3',:section => 'love'
    book.pages.count.should == 4
  end


  it "should have two sections" do
    title = 'test_contents'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'love page1',:author=>'mike1',:content=>'this is the love page1',:section => 'love'
    book.add_page :title=>'love page2',:author=>'mike1',:content=>'this is the love page2',:section => 'love'
    book.add_page :title=>'hate page1',:author=>'mike1',:content=>'this is the hate page1',:section => 'hate'
    book.add_page :title=>'love page3',:author=>'mike1',:content=>'this is the love page3',:section => 'love'
    book.generate
    book.should be_generated
    book.pages_by_section.count.should == 2
  end


  it "can support add_article" do
    title = 'first-book'
    author = 'mike'
    book = Kindler::Book.new :title=>title,:author=>author,:debug=>true
    book.add_article :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.generate
    book.should be_generated
  end

  it "can generate images with relative src" do
    title = 'book_with_relative_image'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:url => 'http://media2.glamour-sales.com.cn/media/some_url',:content=>'<img src="/media/catalog/category/Stroili_banner_02.jpg"/>this is the page 3',:wrap=>true
    book.generate
    book.should be_generated
    File.should be_exist("./#{Kindler::Book::TMP_DIR_PREFIX}#{title}/1.jpg")
  end

  it "should generate mobi books on specify output_dir " do
    title = 'specify_dir'
    custom_dir = '__custom_gen_dir'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true, :output_dir => custom_dir
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.generate
    book.should be_generated
    File.should be_exist(custom_dir)
  end

  it "can generate mobi books on absolute dir" do
    title = 'specify_dir'
    custom_dir = '~/__custom_gen_dir'
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true, :output_dir => custom_dir
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.generate
    book.should be_generated
    File.should be_exist(File.expand_path(custom_dir))
  end

  it "should get correct image type when no extname found" do
    title = "no_extname_found_book"
    book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
    image_url = "https://lh3.googleusercontent.com/Lpu3TQdWzvnJKkx4U4uyjJzQxvXSFTbwbb_Ni3XJp8stydrlKpI_VHbY2rAcphMMcrkq-wev2zKkSpbGSQr_T5BfrRuHYqlLQ-NTPmPk--mS2PYu_Rk"
    book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
    book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
    book.add_page :title=>'page3',:author=>'mike1',:content=>"<img src='#{image_url}'/>this is the page 3",:wrap=>true
    book.generate
    book.should be_generated
  end


end
