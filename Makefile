install:
	bash ./set-up.sh build

build:
	bash ./set-up.sh build

restart:
	bash ./set-up.sh restart

ssl:
	bash ./set-up.sh ssl

destroy:
	bash destroy.sh

uninstall:
	bash destroy.sh
	rm -f .certbot.lock
	rm -fR ./nginx/ssl/*
