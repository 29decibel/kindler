### A kindle mobi book generator
which receive a couple of urls then output one mobi file

#### Input
url1,url2,url3


### Output

book.mobi

### command use
kindler url1 url2 url3 url4 -o test.mobi

outputs : test.mobi

### Api use
```ruby

book = Kindler::Book.new
book.add_page url1
book.add_page url2
book.add_pages url3,url4

book.generate test.mobi
# outputs is test.mobi
```


