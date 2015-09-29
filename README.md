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
* `cap production deploy`: deploy the latest GitHub code to the server
* `cap production deploy:migrate`: run database migrations you've just pushed
* `cap production reindex`: reindex the customer database (in case there's a bug)

You may need to use `bundle exec` to run commands. For instance:
`bundle exec cap production deploy`
