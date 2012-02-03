### Todo
support magzine like format


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

### Command Line Use [Todo]
kindler url1 url2 url3 url4 -t my_book

outputs : my_book.mobi

### Api use
```ruby
# generate my book
book = Kindler::Book.new ({:urls=>["http://blog.farmostwood.net/643.html",
													"http://www.ifanr.com/69878","http://www.oneplus.info/archives/455"],
													:title=>'Test_book',:author=>'mike'})
# you will get my_book.mobi file
book.generate 'my_book'
```


Hope you love it !


