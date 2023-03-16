# Wine-Dotnet

Dockerfile and instructions to run console Windows app based on Dotnet in Linux + Wine.

# How to use

The Dockerfile produces a docker image based on Ubuntu 22.04 with the necessary
Wine components installed, as well as the Microsoft runtime for VC (default:
2022) and Dotnet (default: 4.8).

The image built with that Dockerfile is suitable to run Windows console apps.
The app itself needs to be pre-built on a Windows setup with VC and Dotnet of
the respective versions. Currently, it is not possible to build the app inside
the docker image, since it includes the runtimes only.

To test your windows app (e.g. HelloWorld) using this docker image you need to:

2. On a windows host, compile the app (with VC and Dotnet of matching versions)
3. Copy the resulting folder `bin/Release` to folder `release` on the host
4. Copy any app data files to a new folder `data` on the host

And then, option (1): run the app with generic container using a volume:

5. On your host, build the docker image (only once)
```
    docker build -t wine-dotnet .
```
6. Run the container:
```
    APP_PATH=${path_to_app_release_folder}
    APP_DATA=${path_to_app_data_folder}
    APP_BINARY=HelloWorld.exe
    docker run --rm \
      -v ${APP_PATH}:/app \
      -v ${APP_DATA}:/data \
      wine-dotnet ${APP_BINARY} [ARGS...]
```
or, option(2): build a new image with the app release folder included:

7. Uncomment the "COPY" command in the Dockerfile, and then rebuild:
```
    docker build -t wine-dotnet-app .
```
8. Run the app container:
```
    # use APP_DATA if external app data is needed:
    # APP_DATA=${path_to_app_data_folder}
    APP_BINARY=HelloWorld.exe
    docker run --rm \
      # use APP_DATA if external app data is needed:
      # -v ${APP_DATA}:/data \
      wine-dotnet ${APP_BINARY} [ARGS...]
```

# Contributing

You are welcome to contribute!<br>
For code changes please send [Github PR](https://github.com/orenl/wine-dotnet/pulls).<br>
To report bug, request features, or make suggestions use [Github Issues](https://github.com/orenl/wine-dotnet/issues).<br>
