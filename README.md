# bits_n_bytes_ui

Repository for the UI for the Bits 'n Bytes Project.

## Getting Started

Ensure the [Flutter SDK](https://docs.flutter.dev/install) is installed on your system. Currently, the supported builds are for Linux and MacOS.

## Environment

Create a `.env` file in the root of the directory, following this template:
```
API_URL=
API_AUTH_KEY=
ADMIN_PASSWORD=
```

## Developing over SSH

We recommend developing directly SSH'ed into the system. To do this, ensure you are connected to the same network as the machine.
- Launch Visual Studio Code (or equivialent software) and choose "Connect to Host".
- log in with the given credentials.
- Once you have verified the connection, execute the `run.sh` script to load the application on the pi.