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

1. Run [MariaDB](https://mariadb.org/). `docker run -p 127.0.0.1:3306:3306  --name feminadb-mariadb -e MYSQL_ALLOW_EMPTY_PASSWORD=true -e MYSQL_USER=feminadb_dev -e MYSQL_PASSWORD=feminadb_dev -e MYSQL_DATABASE=feminadb_dev mariadb:10 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci` and load the
   [latest backup](https://console.cloud.google.com/storage/browser/feminadb-backups/?project=feminadb):
   `zcat feminadb-????-??-??_??_??.sql.gz | mysql -h 127.0.0.1 -ufeminadb_dev -pfeminadb_dev feminadb_dev`.
2. [Install rbenv](https://github.com/rbenv/rbenv#installation) and
   [install ruby-build](https://github.com/rbenv/ruby-build#installation)
3. `rbenv install` to install the version of Ruby that FeminaDB relies on
   (specified in `./.ruby-version`)
4. `gem install bundler` (make sure `which ruby` displays something like
   `~/.rbenv/shims/ruby` first -- that is, rbenv is installed correctly
5. `bundle install`
6. In one terminal, `export JAVA_HOME=/usr/lib/jvm/jre-1.8.0; bin/rake sunspot:solr:run`
7. In another temrinal, `bin/rake sunspot:reindex` to build the index
8. `bin/rails s` to start a server
9. Browse to http://localhost:3000 and log in with Google Apps credentials

Running tests
=============

1. `mysql -h 127.0.0.1 --user=root -e "CREATE DATABASE feminadb_test"`
1. `RAILS_ENV=test bin/rake db:migrate`
1. Install [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/)
   and make sure `chromedriver` is in your `PATH`
1. In one shell, `rake sunspot:solr:run`
1. In another shell, `bin/rspec`

Sources
-------

`regions.n_schools` comes from http://opendata.go.tz/dataset/d7baa2ef-93cc-48b8-8296-efda80c288d8/resource/d633dd95-e3fd-4760-bad2-d1675572465f/download/List-of-Registered-Secondary-Schools-2016.csv

`regions.population` comes from the NBS 2012 Census. To get the populations of
Songwe and Mbeya, we looked to http://www.nbs.go.tz/nbs/takwimu/census2012/Tanzania_Total_Population_by_District-Regions-2016.xls
-- it's the 2016 "projection", but since the total population is exactly the
same as in 2012, we assume the breakdown is correct.
