### Prerequisite
#### 1.kindlegen execute file from amazon
#### 2.that's all


### Installation
```ruby
gem 'kindler'
```

or

```ruby
gem 'kindler',:git=>'git@github.com:29decibel/kindler.git'
```
### A kindle mobi book generator
which receive a couple of urls then output one mobi file

### Usage
```ruby
title = 'my_first_mobi_book'
book = Kindler::Book.new :title=>title,:author=>'mike'
book.add_page :title=>'page1',:author=>'mike1',:content=>'this is the page 1',:wrap=>true,:section => 'love'
book.add_page :title=>'page2',:author=>'mike1',:content=>'this is the page 2',:wrap=>true,:section => 'hate'
book.add_page :title=>'page_with_image',:author=>'mike1',:content=>'<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"></img>this is the page 3',:wrap=>true,:section=>'hate'
# you will get my_first_mobi_book.mobi file
book.generate 

#or you can just generate simple mobi book
book.mobi_type = :flat
book.generate
```

Hope you love it !


