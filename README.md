cdb-crawlr
==========

Ruby gem and command-line tool for querying ComicBookDB.com

Installation
------------

https://rubygems.org/gems/cdb-crawlr
```
gem install cdb-crawlr
```

Examples
--------

###### Series Search:
```ruby
irb > CDB::Series.search('Walking Dead')
=> [<struct CDB::Series cdb_id=457, name="The Walking Dead", publisher="Image Comics", start_date="2003">,
    <struct CDB::Series cdb_id=21275, name="Dead Man Walking", publisher="Boneyard Press", start_date="1992">,
    <struct CDB::Series ...]
```
```
bash$ cdb search series Walking Dead
{ "cdb_id": 457, "name": "The Walking Dead", "publisher": "Image Comics", "start_date": "2003" }
{ "cdb_id": 21275, "name": "Dead Man Walking", "publisher": "Boneyard Press", "start_date": "1992" }
...
```

###### Series Display:
```ruby
irb > CDB::Series.show(457) # cdb_id from search
=> <struct CDB::Series
    cdb_id=457,
    name="The Walking Dead",
    publisher="Image Comics",
    imprint="Skybound Entertainment",
    start_date="October 2003",
    end_date="Ongoing",
    issues=
      [<struct CDB::Issue
        cdb_id=257301,
        num="102",
        name="Something to Fear Part Six",
        story_arc="Something to Fear",
        cover_date="September 2012">,
      <struct CDB::Issue ...],
    country="United States",
    language="English">
```
```
bash$ cdb show series 457
{
  "cdb_id": 457,
  "name": "The Walking Dead",
  "publisher": "Image Comics",
  "imprint": "Skybound Entertainment",
  "start_date": "October 2003",
  "end_date": "Ongoing",
  "issues": [
    {
      "cdb_id": 257301,
      "num": "102",
      "name": "Something to Fear Part Six",
      "story_arc": "Something to Fear",
      "cover_date": "September 2012"
    }, ...
  ],
  "country": "United States",
  "language": "English"
}
```
###### Issue Search:
```ruby
irb > CDB::Issue.search('Deadpool')
=> [<struct CDB::Issue cdb_id=14581, series="Wolverine (1988)", num="88", name="It's D-D-Deadpool, Folks!">,
    <struct CDB::Issue cdb_id=60919, series="Ultimate Spider-Man (2000)", num="TPB vol. 16", name="Deadpool">,
    <struct CDB::Issue ...]
```
```
bash$ cdb search issue Deadpool
{ "cdb_id": 14581, "series": "Wolverine (1988)", "num": "88", "name": "It's D-D-Deadpool, Folks!" }
{ "cdb_id": 60919, "series": "Ultimate Spider-Man (2000)", "num": "TPB vol. 16", "name": "Deadpool" }
...
```
