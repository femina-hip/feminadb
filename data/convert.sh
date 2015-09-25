wget http://www.nbs.go.tz/nbs/takwimu/references/GIS_Maps.zip
unzip GIS_Maps.zip
topojson -q 5e3 -s 1e-7 --id-property District_N -o ../public/maps/districts.json Districts.shp
