## Todo
* support inner reference, inner link can take to that article

## Is this gem is what you want?
There is a alternative gem called [kindlerb](https://github.com/danchoi/kindlerb) can generate mobi books, the gem is also used 
for the website [KindleFeeder](http://kindlefeeder.com/) which is build by [Daniel Choi](http://danielchoi.com/software).

If you like to generate mobi book by some html files, you have to conform to the structure which author provide. But if you just 
want to generate mobi book in the fly, then you should try this gem.

BTW, we share the same internal way to generating mobi book by [KindleGen 2](http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000234621).

## Prerequisite
### 1.kindlegen execute file from amazon
### 2.that's all

## Installation
```ruby
gem 'kindler'
```

or

```ruby
gem 'kindler',:git=>'git@github.com:29decibel/kindler.git'
```
## A kindle mobi book generator
which receive a couple of urls then output one mobi file

## Usage
```ruby
title = 'my_first_mobi_book'
book = Kindler::Book.new :title=>title,:author=>'mike'
# add one article
book.add_article {
  :title    =>  'page1',
  :author   =>  'mike1',
  :content  =>  'this is the page 1',
  :section  =>  'love' }
# add another article
book.add_article {
  :title    =>  'page2',
  :author   =>  'mike1',
  :content  =>  'this is the page 2',
  :section  =>  'hate' }
# add an article contains image
book.add_article {
  :title    =>  'page_with_image',
  :author   =>  'mike1',
  :content  =>  '<img src="http://media2.glamour-sales.com.cn/media/catalog/category/Stroili_banner_02.jpg"></img>this is the page 3',
  :section  =>  'hate' }
# you will get my_first_mobi_book.mobi file
book.generate 

#or you can just generate simple mobi book
book.mobi_type = :flat
book.generate
```
> Keep Reading!


