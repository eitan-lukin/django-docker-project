# Docker tag: take from: https://hub.docker.com/_/python
FROM python:3.8-alpine

# maintainer
LABEL maintainer='Stuffed Penguin Studios'

# Tells python to run in unbuffered mode - recommended for docker.
# Python doesn't buffer outputs but outputs them immediately
ENV PYTHONUNBUFFERED 1

# Copy the python package requirements file to the docker image
COPY ./requirements.txt /requirements.txt

# Install the postgresql client
# apk - name of the package manager
# add - add a package
# --update - update the registry before the package is added
# --no cache - Don't store the registry index on the docker file. We do this to minnimize the footprint of the docker image.
# jpeg-dev - jpeg support for Pillow python package
RUN apk add --update --no-cache postgresql-client jpeg-dev

# Install temporary packages to be removed later
# --virtual - set up alias for the dependencies to make them easier to remove later
# musl-dev zlib zlib-dev - Needed for Pillow python package
RUN apk add --update --no-cache --virtual .tmp-build-deps \
      gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev

# Install the python package requirements
RUN pip install -r /requirements.txt

# Remove temporary requirements
RUN apk del .tmp-build-deps

# Create an app folder, make it the default work directory and copy the
# app folder on the local machine to the docker image
RUN mkdir /app
WORKDIR /app
COPY ./app /app

# Create a user (named "user") for running applications only (-D).
# This is for security purposes.
RUN adduser -D user

# Set the user.
USER user
