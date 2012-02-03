require 'spec_helper'
describe "Mobi html file generator" do

	# it "should generate html files by urls" do
	# 	title = "Test_book"
	# 	book = Kindler::Book.new ({:urls=>["http://blog.farmostwood.net/643.html",
	# 														"http://www.ifanr.com/69878","http://www.oneplus.info/archives/455"],
	# 														:title=>title,:author=>'mike',:debug=>true})
	# 	book.generate
	# 	File.exist?(mobi_book_path(title)).should == true
	# end


	# it "should generate hacker news book" do
	# 	title = 'haker_news'
	# 	urls = []
	# 	urls << "http://jseliger.com/2010/09/26/how-universities-work-or-what-i-wish-i%E2%80%99d-known-freshman-year-a-guide-to-american-university-life-for-the-uninitiated/"
	# 	urls << "http://randykepple.com/photoblog/2010/10/8-bad-habits-that-crush-your-creativity-and-stifle-your-success/"
	# 	urls << "http://nathanmarz.com/blog/how-to-get-a-job-at-a-kick-ass-startup-for-programmers.html"
	# 	urls << "http://tumblr.intranation.com/post/766290565/how-set-up-your-own-private-git-server-linux"
	# 	urls << "http://antirez.com/post/what-is-wrong-with-2006-programming.html"
	# 	urls << "http://fak3r.com/2009/09/14/howto-build-your-own-open-source-dropbox-clone/"
	# 	book = Kindler::Book.new :urls=>urls,:title=>title,:author=>'mike',:debug=>true
	# 	book.generate 
	# 	File.exist?(mobi_book_path(title)).should == true
	# end

	# it "should generate book and infos on output_dir" do
	# 	title = 'my_dir_book'
	# 	urls = []
	# 	urls << "http://www.wowsai.com/home/space.php?uid=1&do=blog&id=4362&classid=2"
	# 	urls << "http://www.honeykennedy.com/2012/01/miss-moss-love-letters/"
	# 	urls << "http://www.mysenz.com/?p=3692"
	# 	book = Kindler::Book.new :urls=>urls,:title=>title,:author=>'mike',:output_dir=>'/Users/lidongbin/projects',:debug=>true
	# 	book.generate 
	# 	File.exist?(mobi_book_path(title,'/Users/lidongbin/projects')).should == true
	# end

	it "should not say error when got redirect page" do
		title = 'good_book'
		urls = []
		urls << "http://droplr.com"
		urls << "http://www.mysenz.com/?p=3692"
		book = Kindler::Book.new :urls=>urls,:title=>title,:author=>'mike',:debug=>true
		book.generate 
		File.exist?(mobi_book_path(title)).should == true
	end

	def mobi_book_path(title,output_dir='.')
		File.join(output_dir,"kindler_generated_mobi_#{title}/#{title}.mobi")
	end


			# this navPoint seems not useful
			# contents << <<-NAV
			# <navPoint id="navpoint-1" playOrder="1">
			# 	<navLabel><text>Table Of Contents</text></navLabel>
			# 	<content src="contents.html"/>
			# </navPoint>
			# NAV
			####################### periodocal , magzine like format #########################
			# <navPoint playOrder="0" class="periodical" id="periodical">
			#			<mbp:meta-img src="masthead.gif" name="mastheadImage"/>
			#			<navLabel>
			#				<text>Table of Contents</text>
			#			</navLabel>
			#			<content src="contents.html"/>
			#			<navPoint playOrder="1" class="section" id="Main-section">
			#				<navLabel>
			#					<text>Main section</text>
			#				</navLabel>
			#				<content src="001.html"/>
			#				<navPoint playOrder="2" class="article" id="item-001">
			#					<navLabel>
			#						<text>Nick Clegg and David Cameron agree key changes on NHS plans</text>
			#					</navLabel>
			#					<content src="001.html"/>
			#					<mbp:meta name="description">Deputy PM tells Andrew Marr show that GPs should not be forced to sign up to new commissioning consortiums</mbp:meta>
			#					<mbp:meta name="author">Nicholas Watt and Denis Campbell</mbp:meta>
			#				</navPoint>
			# ####################################################################################


end
