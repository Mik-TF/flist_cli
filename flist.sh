#!/bin/bash
# Filename flist.sh

TOKEN_FILE="$HOME/.token"

login() {
    local token_exists=false
    local docker_logged_in=false

    if [ -f "$TOKEN_FILE" ]; then
        token_exists=true
    fi

    if docker info >/dev/null 2>&1; then
        if docker info | grep -q "Username"; then
            docker_logged_in=true
        fi
    fi

    if $token_exists && $docker_logged_in; then
        echo "You are already logged in to Docker Hub and your Flist Hub token is present."
        return 0
    fi

    if ! $token_exists; then
        read -p "Please enter your tfhub token: " tfhub_token
        echo "$tfhub_token" > "$TOKEN_FILE"
        echo "Token saved in $TOKEN_FILE."
        echo "To use this token in other sessions, add the following line to your ~/.bashrc or ~/.bash_profile:"
        echo "export TOKEN=\$(cat $TOKEN_FILE)"
    else
        echo "Your Flist Hub token is already saved."
    fi

    if ! $docker_logged_in; then
        echo "Logging in to Docker Hub..."
        if sudo docker login; then
            echo "Successfully logged in to Docker Hub."
        else
            echo "Failed to log in to Docker Hub."
            return 1
        fi
    else
        echo "Already logged in to Docker Hub."
    fi

    echo "Login process completed."
}

logout() {
    if [ ! -f "$TOKEN_FILE" ]; then
        echo "You are not logged in."
        return 1
    fi

    rm "$TOKEN_FILE"
    sudo docker logout

    echo "You are now logged out of Docker Hub and your Flist Hub token has been removed."
}

push() {
    if [ $# -ne 1 ]; then
        echo "Error: Incorrect number of parameters."
        echo "Usage: $0 push <name>:<tag>"
        echo "Please provide exactly one parameter."
        exit 1
    fi

    tag=$1

    sudo docker login

    docker_user=$(sudo docker system info | grep 'Username' | cut -d ' ' -f 3)
    full_tag=${docker_user}/${tag}

    if [ -f "$TOKEN_FILE" ]; then
        tfhub_token=$(cat "$TOKEN_FILE")
    else
        echo "Error: No token found. Please run '$0 login' first."
        exit 1
    fi

    echo "Starting Docker build"
    sudo docker buildx build -t $full_tag .

    echo "Finished local Docker build, now pushing to Docker Hub"
    sudo docker push $full_tag

    echo "Converting Docker image to flist now..."
    curl -sS -X POST -F image=$full_tag -H "Authorization: bearer $tfhub_token" https://hub.grid.tf/api/flist/me/docker

    hub_user=$(curl -s -H "Authorization: bearer $tfhub_token" https://hub.grid.tf/api/flist/me | jq -r .payload.username)

    echo "Conversion attempt completed, check above for success"
    echo "Here are paths matching the tag name:"
    url=https://hub.grid.tf/api/flist/${hub_user}
    curl -sS $url | jq -c '.[]' | while read i; do
        if echo $i | grep -q $(echo $tag | cut -d ':' -f 1); then
            echo https://hub.grid.tf/${hub_user}/$(echo $i | jq -r .name)
        fi
    done
}

delete() {
    if [ $# -ne 1 ]; then
        echo "Error: Incorrect number of parameters."
        echo "Usage: $0 delete <flist_name>"
        echo "Please provide exactly one parameter."
        exit 1
    fi

    flist_name=$1

    if [ -f "$TOKEN_FILE" ]; then
        tfhub_token=$(cat "$TOKEN_FILE")
    else
        echo "Error: No token found. Please run '$0 login' first."
        exit 1
    fi

    echo "Deleting flist: $flist_name"
    curl -H "Authorization: bearer $tfhub_token" https://hub.grid.tf/api/flist/me/$flist_name -X DELETE
    echo "Deletion request sent."
}

rename() {
    if [ $# -ne 2 ]; then
        echo "Error: Incorrect number of parameters."
        echo "Usage: $0 rename <flist_name> <new_flist_name>"
        echo "Please provide exactly two parameters."
        exit 1
    fi

    flist_name=$1
    new_flist_name=$2

    if [ -f "$TOKEN_FILE" ]; then
        tfhub_token=$(cat "$TOKEN_FILE")
    else
        echo "Error: No token found. Please run '$0 login' first."
        exit 1
    fi

    echo "Renaming flist: $flist_name to $new_flist_name"
    curl -H "Authorization: bearer $tfhub_token" https://hub.grid.tf/api/flist/me/$flist_name/rename/$new_flist_name -X GET
    echo "Rename request sent."
}

help() {
    cat << EOF
$(tput bold)$(tput setaf 2)
 Welcome to the Flist CLI!
$(tput sgr0)
This tool turns Dockerfiles and Docker images directly into Flist on the TF Flist Hub, passing by the Docker Hub.

$(tput bold)Available commands:$(tput sgr0)
  $(tput setaf 4)login$(tput sgr0)  - Log in to Docker Hub and save the Flist Hub token
  $(tput setaf 4)logout$(tput sgr0) - Log out of Docker Hub and remove the Flist Hub token
  $(tput setaf 4)push$(tput sgr0)   - Build and push a Docker image to Docker Hub, then convert and push it as an flist to Flist Hub
  $(tput setaf 4)delete$(tput sgr0) - Delete an flist from Flist Hub
  $(tput setaf 4)rename$(tput sgr0) - Rename an flist in Flist Hub
  $(tput setaf 4)help$(tput sgr0)   - Display this help message

$(tput bold)Usage:$(tput sgr0)
  flist login
  flist logout
  flist push <image>:<tag>
  flist delete <flist_name>
  flist rename <flist_name> <new_flist_name>
  flist help
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        push)
            if [ $# -eq 2 ]; then
                push "$2"
            else
                echo "Usage: $0 push <image>:<tag>"
                exit 1
            fi
            ;;
        login)
            login
            ;;
        logout)
            logout
            ;;
        delete)
            if [ $# -eq 2 ]; then
                delete "$2"
            else
                echo "Usage: $0 delete <flist_name>"
                exit 1
            fi
            ;;
        rename)
            if [ $# -eq 3 ]; then
                rename "$2" "$3"
            else
                echo "Usage: $0 rename <flist_name> <new_flist_name>"
                exit 1
            fi
            ;;
        help)
            help
            ;;
        *)
            echo "Unknown command. Use '$0 help' for usage information."
            exit 1
            ;;
    esac
fi