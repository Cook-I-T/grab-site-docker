ARG PYTHON_VERSION=3.8
ARG ALPINE_VERSION=3.20

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

WORKDIR /app
VOLUME [ "/data" ]

ENV GRAB_SITE_INTERFACE=0.0.0.0
ENV GRAB_SITE_PORT=29000
ARG GRAB_SITE_HOST=gs-server
ENV GRAB_SITE_HOST=${GRAB_SITE_HOST}
EXPOSE 29000

# Add user and group for grab-site
RUN addgroup -g 10000 -S grab-site \
	&& adduser -u 10000 -S -G grab-site grab-site \
	&& chown -R grab-site:grab-site $(pwd) \
	&& mkdir -p /data \
	&& chown -R grab-site:grab-site /data

# Install system dependencies
RUN apk add --no-cache \
		su-exec>=0.2 \
		git \
		gcc \
		libxml2-dev \
		musl-dev \
		libxslt-dev \
		g++ \
		py3-pybind11-dev abseil-cpp-dev re2-dev \
		libffi-dev \
		openssl-dev \
		patch \
	&& ln -s /usr/include/libxml2/libxml /usr/include/libxml

ENV PATH="/app:$PATH"
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "gs-server" ]

# TODO: resolve dependencies before loading library code to take advantage of build caching
# 	setup.py requires libgrabsite/__init__.py (__version__ property) to work

# Copy application files
COPY --chown=grab-site:grab-site . .

# Install application dependencies
RUN pip install --no-cache-dir .

# Set up runtime environment
WORKDIR /data

# docker build -t grab-site:latest .
# docker run --rm -it --entrypoint sh grab-site:latest
# docker network create -d bridge gs-network
# docker run --net=gs-network --name=gs-server -d -p 29000:29000 --restart=unless-stopped grab-site:latest
# docker run --net=gs-network --rm -d -e GRAB_SITE_HOST=gs-server -v ./data:/data:rw grab-site:latest grab-site https://www.example.com/
# docker run --net=gs-network --rm -d -e GRAB_SITE_HOST=gs-server -v C:\projects\grab-site\data:/data:rw grab-site:latest grab-site https://www.example.com/
