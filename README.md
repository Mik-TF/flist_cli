# Flist CLI

## Table of Contents

- [Flist CLI](#flist-cli)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Uninstallation](#uninstallation)
  - [Usage](#usage)
    - [Examples](#examples)
  - [Support](#support)
  - [References](#references)

---

## Introduction

Flist CLI is a command-line tool that simplifies the process of turning Dockerfiles and Docker images into Flists on the TF Flist Hub, using Docker Hub as an intermediary.

## Prerequisites

- Ensure you have Docker installed and configured on your system.
- You'll need a Docker Hub account and a TF Flist Hub token to use this tool.
- The tool stores your TF Flist Hub token in `~/.config/tfhubtoken`. Keep this file secure.
  - You can run `flist logout` to remove this file and log out from Docker.

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/Mik-TF/flist_cli.git
   ```

2. Navigate to the cloned directory:
   ```
   cd flist_cli
   ```

3. Install the tool:
   ```
   bash flist.sh install
   ```

   This will create an executable named `flist` in `/usr/local/bin/`.

## Uninstallation

To uninstall the Flist CLI, run:
```
flist uninstall
```

## Usage

The Flist CLI provides several commands:

- `install`: Install the Flist CLI
- `uninstall`: Uninstall the Flist CLI
- `login`: Log in to Docker Hub and save the Flist Hub token
- `logout`: Log out of Docker Hub and remove the Flist Hub token
- `push`: Build and push a Docker image to Docker Hub, then convert and push it as an flist to Flist Hub
- `delete`: Delete an flist from Flist Hub
- `rename`: Rename an flist in Flist Hub
- `help`: Display help information

### Examples

1. Install the CLI:
   ```
   bash flist.sh install
   ```

2. Log in:
   ```
   flist login
   ```

3. Push a Docker image and convert it to an flist:
   ```
   flist push myimage:latest
   ```

4. Delete an flist:
   ```
   flist delete myflist.flist
   ```

5. Rename an flist:
   ```
   flist rename old_name.flist new_name.flist
   ```

6. Log out:
   ```
   flist logout
   ```

7. Display help information:
   ```
   flist help
   ```

8. Uninstall the CLI:
   ```
   flist uninstall
   ```

## Support

If you encounter any issues or have questions, please open an issue on the [GitHub repository](https://github.com/Mik-TF/flist_cli).

## References

- This work is done for ThreeFold in collaboration with Scott Yeager, see [this story](https://git.ourworld.tf/tfgrid/circle_engineering/issues/97) for context.
- The script is based on Scott's first version [here](https://gist.github.com/scottyeager/2c5826e0aa952ddc7a05080b60efdbbe).