This is of use to Femina HIP Ltd., and probably nobody else.

I haven't documented it; I'm using GitHub as a backup, hence this README.

Installation
============

To install on Google Cloud, run `script/launch-google-cloud-instance.sh`. Read
the comments therein to find other requirements....

Upkeep
------

Commands you may need:

* `bundle install`: set up your development environment
* `git add`, `git commit`, `git push`: push new code to GitHub
* `bin/cap production deploy`: deploy the latest GitHub code to the server
* `bin/cap production deploy:migrate`: run database migrations you've just pushed
* `bin/cap production reindex`: reindex the customer database (in case there's a bug)

You may need to use `bundle exec` to run commands. For instance:
`bundle exec cap production deploy`

Development mode
================

1. Install [MariaDB](https://mariadb.org/). Create a user/pass/db named
   `feminadb_dev` (give `feminadb_dev` ALL PRIVILEGES) and copy in data from the
   [latest backup](https://console.cloud.google.com/storage/browser/feminadb-backups/?project=feminadb)
2. [Install rbenv](https://github.com/rbenv/rbenv#installation) and
   [install ruby-build](https://github.com/rbenv/ruby-build#installation)
3. `rbenv install` to install the version of Ruby that FeminaDB relies on
   (specified in `./.ruby-version`)
4. `gem install bundler` (make sure `which ruby` displays something like
   `~/.rbenv/shims/ruby` first -- that is, rbenv is installed correctly
5. `bundle install`
6. In one terminal, `rake sunspot:solr:run`
7. In another temrinal, `rake sunspot:reindex` to build the index
8. `bin/rails s` to start a server
9. Browse to http://localhost:3000 and log in with Google Apps credentials

Running tests
=============

1. `RAILS_ENV=test bin/rake db:migrate`
1. In one shell, `RAILS_ENV=test rake sunspot:solr:run`
1. In another shell, `bin/rspec`

Sources
-------

`regions.n_schools` comes from http://opendata.go.tz/dataset/d7baa2ef-93cc-48b8-8296-efda80c288d8/resource/d633dd95-e3fd-4760-bad2-d1675572465f/download/List-of-Registered-Secondary-Schools-2016.csv

`regions.population` comes from the NBS 2012 Census. To get the populations of
Songwe and Mbeya, we looked to http://www.nbs.go.tz/nbs/takwimu/census2012/Tanzania_Total_Population_by_District-Regions-2016.xls
-- it's the 2016 "projection", but since the total population is exactly the
same as in 2012, we assume the breakdown is correct.
