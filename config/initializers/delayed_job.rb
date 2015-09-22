# Some classes need to be loaded when running in development mode: otherwise,
# when the delayed_job script tries loading them from the database, they come
# back as raw objects. 
#
# All we have to do is name the class: Ruby will load it, then when DelayedJob
# uses "YAML.load()" on a string which includes that class, everything will run
# smoothly.

#BulkOrderCreator # FIXME uncomment this
