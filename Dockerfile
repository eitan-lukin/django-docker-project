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
RUN apk add --update --no-cache postgresql-client

# Install temporary packages to be removed later
# --virtual - set up alias for the dependencies to make them easier to remove later
RUN apk add --update --no-cache --virtual .tmp-build-deps \
      gcc libc-dev linux-headers postgresql-dev

# Install the python package requirements
RUN pip install -r /requirements.txt

# Remove temporary requirements
RUN apk del .tmp-build-deps

# Create an app folder, make it the default work directory and copy the
# app folder on the local machine to the docker image
RUN mkdir /puppy_store
WORKDIR /puppy_store
COPY ./puppy_store /puppy_store

# Create a user (named "user") for running applications only (-D).
# This is for security purposes.
RUN adduser -D user

# Set the user.
USER user
