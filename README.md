cdb-crawlr
==========

Ruby gem and command-line tool for querying ComicBookDB.com

### Getting Started

Install the gem: https://rubygems.org/gems/cdb-crawlr

    gem install cdb-crawlr

##### Supported Actions:

###### Title Search:
```ruby
irb > require 'cdb-crawlr'
irb > CDB::Title.search('Walking Dead')
#=> [#<struct CDB::Title cdb_id="457", name="The Walking Dead", publisher="Image Comics", begin_date="2003", end_date=nil>,
     #<struct CDB::Title cdb_id="21275", name="Dead Man Walking", publisher="Boneyard Press", begin_date="1992", end_date=nil>,
     #<struct CDB::Title ...]
```
```
bash$ cdb search --scope=title Walking Dead
{ "cdb_id": 457, "name": "The Walking Dead", "publisher": "Image Comics", "begin_date": "2003", "end_date": null }
{ "cdb_id": 21275, "name": "Dead Man Walking", "publisher": "Boneyard Press", "begin_date": "1992", "end_date": null }
...
```

###### Issue Search:
```ruby
irb > require 'cdb-crawlr'
irb > CDB::Issue.search('Deadpool')
#=> [#<struct CDB::Issue cdb_id="14581", title="Wolverine (1988)", num="#88", name="It's D-D-Deadpool, Folks!", cover_date=nil>,
     #<struct CDB::Issue cdb_id="60919", title="Ultimate Spider-Man (2000)", num="TPB vol. 16", name="Deadpool", cover_date=nil>,
     #<struct CDB::Issue ...]
```
```
bash$ cdb search --scope=issue Deadpool
{ "cdb_id": 14581, "title": "Wolverine (1988)", "num": "#88", "name": "It's D-D-Deadpool, Folks!", "cover_date": null }
{ "cdb_id": 60919, "title": "Ultimate Spider-Man (2000)", "num": "TPB vol. 16", "name": "Deadpool", "cover_date": null }
...
```