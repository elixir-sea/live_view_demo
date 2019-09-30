# Deployment

1. Make sure heroku CLI is installed and that you have permissions to
   deploy the app there.
1. `heroku login`
1. make sure Docker is installed
1. Build the Docker image
    ```
    $ bin/docker-build
    ```
1. Push the Docker image
    ```
    $ bin/docker-push
    ```
1. Release the docker image to the heroku app:
    ```
    $ heroku container:release web
    ```
