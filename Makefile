dummy:

build:
	docker build -t hoarder-cache .

enter:
	docker run -i -t hoarder-cache bash

run:
	docker run -t hoarder-cache /sbin/init
