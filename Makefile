PATH := node_modules/.bin:$(PATH)
WIDTH := 960
HEIGHT := 960

test.svg: data/departements.json
	geo2svg -w $(WIDTH) -h $(HEIGHT) < $< > $@

data/departements.json: data/projected.json
	geo2topo metropole=$< \
	| topomerge -k 'd.properties.insee.slice(0,2)' metropole=metropole \
	| toposimplify -p 1 -f \
	| topo2geo metropole=$@

data/projected.json: data/metropole.json
	geoproject 'd3.geoConicConformal().parallels([44, 49]).rotate([-3, 0]).fitSize([$(WIDTH), $(HEIGHT)], d)' < $< > $@

data/metropole.json: data/communes.json
	ndjson-split 'd.features' < $< \
	| ndjson-filter '+d.properties.insee.slice(0,1) < 9 || +d.properties.insee.slice(1,2) <= 5' \
	| ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}' > $@

data/communes.json: raw/communes-20150101-100m.shp raw/communes-20150101-100m.dbf
	shp2json $< --encodinf utf-8 -o $@
