## Release

We're releasing to Google Cloud in this class using [docker-machine](https://docs.docker.com/machine/).

First, install the docker-machine tool from the [https://docs.docker.com/machine/](https://docs.docker.com/machine/) page.

Once we have this dependency, we will need to build a docker image to run our application from within. We'll use some default docker functions to do this.

### Build a docker machine on google cloud

In order to build into a docker image, we'll need a machine running docker. Docker-machine makes this pretty easy. 

> ## Why docker-machine
>
> Docker-machine makes building docker environments in multiple platforms simple. In this case, we'll be building against the google cloud engine, but we can just as easily build our environment with aws, virtualbox, or any other cloud provider supported by docker-machine. 

Let's create a google cloud environment with docker-machine where our docker image will live. In order to do this, we'll need to sign up for GCE at the google cloud platform page at [https://console.cloud.google.com/home/dashboard](https://console.cloud.google.com/home/dashboard)

![](./assets/create-project-1)

Create a project we'll work within. In our example, we'll work in a project called `elixir-bridge`, but we can name is anything we want. Next, we'll need to enable the google compute apis in this project. 

Find the Library tab and search for the compute api

![](./assets/enable-cloud-api-1)

Find the compute api and navigate to the page. Here, find the `Enable` button and enable the API for this project.

### Building a docker environment

With the GCE (google cloud engine) side setup, let's create the google container environment. We'll use the docker-machine command to create an app environment. 

```bash
docker-machine create --driver google \
          --google-project [YOUR_PROJECT_ID] \
          --google-zone us-central1-a \
          --google-machine-type f1-micro \
          elixir-experiment
```

When we run this command, we'll have an environment set up for our docker containers to run. In order for us to operate in the docker container, we'll need to set up some environment variables to manipulate the docker environment. Luckily, docker-machine makes this easy as well.

In our terminal, let's execute the following:

```bash
eval $(docker-machine env elixir-experiment)
```

This command adds a few environment variables to our shell, which tells our docker command-line tool which docker server to communicate. Try typing the following in our terminal:

```bash
docker ps
```

If everything works, this will list an empty list of docker machines. 

Once this is set up, we're ready to create our docker instance build system.

## Creating a reproducible deployment

Once nice feature of using Docker is it's ability to create reproducible environments.