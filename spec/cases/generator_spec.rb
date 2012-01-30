require 'spec_helper'
describe "Mobi html file generator" do

	it "should generate html files by urls" do
		title = "Test_book"
		book = Kindler::Book.new ({:urls=>["http://blog.farmostwood.net/643.html",
															"http://www.ifanr.com/69878","http://www.oneplus.info/archives/455"],
															:title=>title,:author=>'mike',:debug=>true,:tags=>%w(div p img)})
		book.generate
		File.exist?(mobi_book_path(title)).should == true
	end


	it "should generate hacker news book" do
		title = 'haker_news'
		urls = []
		urls << "http://jseliger.com/2010/09/26/how-universities-work-or-what-i-wish-i%E2%80%99d-known-freshman-year-a-guide-to-american-university-life-for-the-uninitiated/"
		urls << "http://randykepple.com/photoblog/2010/10/8-bad-habits-that-crush-your-creativity-and-stifle-your-success/"
		urls << "http://nathanmarz.com/blog/how-to-get-a-job-at-a-kick-ass-startup-for-programmers.html"
		urls << "http://tumblr.intranation.com/post/766290565/how-set-up-your-own-private-git-server-linux"
		urls << "http://antirez.com/post/what-is-wrong-with-2006-programming.html"
		urls << "http://fak3r.com/2009/09/14/howto-build-your-own-open-source-dropbox-clone/"
		book = Kindler::Book.new :urls=>urls,:title=>title,:author=>'mike',:debug=>true
		book.generate 
		File.exist?(mobi_book_path(title)).should == true
	end

	it "should generate book and infos on output_dir" do
		title = 'my_dir_book'
		urls = []
		urls << "http://www.wowsai.com/home/space.php?uid=1&do=blog&id=4362&classid=2"
		urls << "http://www.honeykennedy.com/2012/01/miss-moss-love-letters/"
		urls << "http://www.mysenz.com/?p=3692"
		book = Kindler::Book.new :urls=>urls,:title=>title,:author=>'mike',:output_dir=>'/Users/lidongbin/projects',:debug=>true
		book.generate 
		File.exist?(mobi_book_path(title,'/Users/lidongbin/projects')).should == true
	end

	def mobi_book_path(title,output_dir='.')
		File.join(output_dir,"kindler_generated_mobi_#{title}/#{title}.mobi")
	end

end
