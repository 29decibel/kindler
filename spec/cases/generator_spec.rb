require 'spec_helper'
describe "Mobi html file generator" do

	it "should not generate a mobi book" do
		title = 'good_book'
		book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
		book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
		book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
		book.add_page :title=>'page3',:author=>'mike1',:content=>'this is the page 3',:wrap=>true
		book.generate 
		File.exist?(mobi_book_path(title)).should == true
	end

	it "should generate book contains images" do
		title = 'book_with_image'
		book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
		book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true
		book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true
		book.add_page :title=>'page3',:author=>'mike1',:content=>'<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"></img>this is the page 3',:wrap=>true
		book.generate 
		File.exist?(mobi_book_path(title)).should == true
	end

	it "should generate book with sections" do
		title = 'first_section_book'
		book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
		book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true,:section => 'love'
		book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true,:section => 'hate'
		book.add_page :title=>'page3',:author=>'mike1',:content=>'<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"></img>this is the page 3',:wrap=>true,:section=>'hate'
		book.generate 
		File.exist?(mobi_book_path(title)).should == true
	end

	it "should contains right info at contents html" do
		title = 'test_contents'
		book = Kindler::Book.new :title=>title,:author=>'mike',:debug=>true
		book.add_page :title=>'love page1',:author=>'mike1',:content=>'this is the love page1',:section => 'love'
		book.add_page :title=>'love page2',:author=>'mike1',:content=>'this is the love page2',:section => 'love'
		book.add_page :title=>'hate page1',:author=>'mike1',:content=>'this is the hate page1',:section => 'hate'
		book.add_page :title=>'love page3',:author=>'mike1',:content=>'this is the love page3',:section => 'love'
		book.add_page :title=>'hate page2',:author=>'mike1',:content=>'<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"></img>this is the hate page2',:section=>'hate'
		book.generate 
		book.pages[2][:title].should == 'love page3'
	end

	it "should contains right info at ncx file" do
		
	end

	it "should contains right info at opf file" do
		
	end

	def mobi_book_path(title,output_dir='.')
		File.join(output_dir,"kindler_generated_mobi_#{title}/#{title}.mobi")
	end

end
