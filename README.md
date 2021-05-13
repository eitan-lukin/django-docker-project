# **Using Docker with Django REST Framework**

Docker is an open-source project for automating the deployment of applications as
portable, self-sufficient containers that can run on the cloud or on-premises.
It can be good practice to employ the use of docker during the development stages
of a project to assure that the project is "always alive".

### **Python "requirements.txt" file:**
```
Django>=3.1.7,<3.2.0
djangorestframework>=3.12.4,<3.13.0
psycopg2>=2.8.6,<2.9
Pillow>=8.2.0,<8.3.0
flake8>=3.9.1,<3.10.0
```

### **Dockerfile:**
```Dockerfile
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
RUN mkdir /puppy_store
WORKDIR /puppy_store
COPY ./puppy_store /puppy_store

# Create a user (named "user") for running applications only (-D).
# This is for security purposes.
RUN adduser -D user

# Set the user.
USER user


```

### **docker-compose.yml:**
```YAML
# Version of docker compose
version: "3"

# Define the services that make up the application
services:
  # Name of the service (puppy_store)
  app:
    build:
      context: .
    # Set ports
    port:
      - "8000:8000"
    # Map the volume in the local machine into the docker container
    # that runs the application in order to update changes made to
    # the code in real time without having to restart Docker.
    volumes:
      - ./<appname>:/<appname>
    # Run the django developement server on all IP addresses
    #  that run the container. Conects on port 8000.
    # Command to start the service when running "docker-compose up"
    command: >
      sh -c "python manage.py wait_for_db &&
             python manage.py migrate &&
             python manage.py runserver 0.0.0.0:8000"
    # set the environment variables
    environment:
      # Use the db service (created separately)
      - DB_HOST=db
      # Name of the new db service db
      - DB_NAME=appname
      - DB_USER=postgres
      - DB_PASS=supersecretpassword
    depends_on:
      # Makes this service go up after the db service and makes the db service available when the app is running.
      - db
  # Set the DB service when using a different type of DB (default for django is sqlite)
  db:
    # Locate image (postgres) in docker hub and pull the version with the tag (10-alpine)
    image: postgres:10-alpine
    # environment variables to be created when the DB service starts
    environment:
        - POSTGRES_DB=app
        - POSTGRES_USER=postgres
        # In production don't use this password but rather, in your build server you should add an encrypted password that overrides this.
        - POSTGRES_PASSWORD=supersecretpassword
```

### Docker commands
Build the docker image:<br>
`docker-compose build`

### **Using docker-compose during production:**

Instead of running the usual python command, run:

`docker-compose run --rm <appname> sh -c <command>`<br>
--rm: <br>
sh: run a shell script<br>
-c: execute the following command in the sheel script<br>

For example:<br>
`docker-compose run --rm app sh -c django-admin startproject app .`<br>
`docker-compose run --rm app sh -c python manage.py test && flake8`<br>
