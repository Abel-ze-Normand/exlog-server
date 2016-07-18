# SdvorLogger

Logger server. In folder 'logger_service_py' located python module for connection to logger service. Dockerfile included.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sdvor_logger` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sdvor_logger, "~> 0.1.0"}]
    end
    ```

  2. Ensure `sdvor_logger` is started before your application:

    ```elixir
    def application do
      [applications: [:sdvor_logger]]
    end
    ```

  3. Ensure that zeromq installed

  4. Ensure that mongo container is available! And provide link to this container or alias

    ```
    docker run -it --link MongoDB_Queue_msgs --rm mongo sh -c 'exec mongo 'MongoDB_Queue_msgs:27017/queue_msgs''
    ```

  5. Mongo container can be used as-is, no customizations, only remember to mount volume to have access to data

  6. Any application-client that want to use logger, must be launched linked to logger container

    ```
    docker run --name my_app --link logger_service my_app_image
    ```
  7. It's advised to install pyzmq independent, because pyzmq binaries are sensitive to used version.
    ```python
    pip install pyzmq --no-binary
    ```
  8. To connect to mongo container and access data:
    ```
    docker run -it --link MongoDB_Queue_msgs --rm mongo sh -c 'exec mongo 'MongoDB_Queue_msgs:27017/queue_msgs''
    ```
  9. Dependencies list: mongo <---- logger <----- application
