IMAGE=molobrakos/tellsticknet

default: check

install:
	uv sync --all-extras

format: white

white: black

black:
	black tellsticknet
	white tellsticknet

lint:
	flake8 tellsticknet
	pylint -E tellsticknet
	yamllint tellsticknet-sample.conf

test:
	pytest tellsticknet

check: lint test

clean:
	rm -rf *.egg-info
	rm -rf .pytest_cache
	rm -rf dist
	rm -rf build
	rm -rf .cache
	rm -f *~
	rm -f .*~

build:
	uv build

pypi: clean build
	uv publish

release:
	git diff-index --quiet HEAD -- && make check && git push && make pypi

docker-build:
	docker build -t $(IMAGE) .

docker-run-mqtt:
	docker run \
                --name=tellsticknet \
		--restart=always \
		--detach \
		--net=bridge \
		-p 30303:30303/udp \
		-p 42314:42314/udp \
		-v $(HOME)/.config/mosquitto_pub:/app/.config/mosquitto_pub:ro \
		-v $(HOME)/.config/tellsticknet.conf:/app/tellsticknet.conf:ro \
		$(IMAGE) -vv

docker-run-mqtt-term:
	docker run \
		-ti --rm \
                --name=tellsticknet \
		--net=bridge \
		-p 30303:30303/udp \
		-p 42314:42314/udp \
		-v $(HOME)/.config/mosquitto_pub:/app/.config/mosquitto_pub:ro \
		-v $(HOME)/.config/tellsticknet.conf:/app/tellsticknet.conf:ro \
		$(IMAGE) -vv
