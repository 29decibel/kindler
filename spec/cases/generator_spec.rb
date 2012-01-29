require 'spec_helper'
describe "Mobi html file generator" do

	it "should generate html files by urls" do
		book = Kindler::Book.new ({:urls=>["http://blog.farmostwood.net/643.html",
															"http://www.ifanr.com/69878","http://www.oneplus.info/archives/455"],
															:title=>'Test_book',:author=>'mike'})
		book.generate 'test'
		# check files
	end
end
