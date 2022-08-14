# k8s-basic-project

## Project Description
This repository holds necessary setup and steps to deploy a website on local kubernetes cluster.<br>
It uses `kind` to create local cluster and deploy a static website (html, css, js) using kubernates object manifest templates handled by `helm` charts. All the applications are containerized using `docker` containers.

| Table Of Contents           |
| --------------------------- |
| Pre-requisites              |
| Steps For Launching Website |
| Cleanup                     |


## Pre-requisites : 

Install [Docker](https://docs.docker.com/engine/install/) <br>
Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) <br>
Install [kubectl](https://kubernetes.io/docs/tasks/tools/) <br>
Install [Helm](https://helm.sh/docs/intro/install/) <br>
Install make <br>

> Note: All installations to be done such that executable are available from anywhere on the system (should be added in one of the locations mentioned in PATH variable)


## Steps For Launching Website : 

1. Make sure pre-requisites are satisfied.

2. Copy your website code (having index.html) in website folder.

3. Launch website using docker.<br>

    Execute below command <br>
    ```
    make run \
    imageName=<name_of_image> \
    imageTag=<version_of_image> \
    containerName=<name_of_container> \
    hostPort=<port_on_host_machine>
    ```
    This creates an image and uses it to run a container for the website.

    Make sure your website is accessible on your browser at `http://127.0.0.1:<hostPort>` <br>

    If website is accessible, it means created image is working as expected. One can stop the container as we will be deploying the same using kubernetes later. To stop, run <br>
    ```
    make stop \
    containerName=<name_of_container>
    ```
    
    As image is a stable one now, it will be used later.

4. Create local cluster & registry. Connect them to each other. <br>

    Run below command,
    ```
    make create_kind_cluster_with_registry \
    clusterName=<name_of_cluster>
    ```

    This will 
    - launch a container on port `5000` which will act as image registry for our kubernetes cluster. Verify it by ensuring `local-registry` container is running.
    - Create a kind k8s cluster with a node (control plane) as a docker container. Verify it by ensuring `<clusterName>-control-plane` container is running. Also ensure `<clusterName>` is output for command `sudo kind get clusters`
    - Connect local-resgitry to kind (cluster) network

5. Push website image to local-registry <br>
    ```
    make push_image_to_local_registry \
    imageName=<name_of_image> \
    imageTag=<version_of_image>
    ```

    Note: `imageName` & `imageTag` should be the one provided in *step 3*

6. Install ingress controller for cluster <br>
    ```
    sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    ```

    Multiple kubernetes resources will be created in ingress-nginx namespace. To check, run <br>
    ```
    sudo kubectl get all -n ingress-nginx
    ``` 
    
    > Note: Make sure pods are in either completed or running state.

7. Change variables and values in chart <br><br>

    Refer the comments mentioned and change the values as per requirement <br>
    in `Chart.yaml` & `values.yaml` files in  `cluster/chart/`

8. Deploy Website <br>
    ```
    make install_app
    ```

    This will run your deployment using `helm` and get your app up on kubernetes cluster

9. Resolve Hostname Locally <br><br>

    To resolve dns locally for your hostname, create an entry in `/etc/hosts`.<br> 
    Insert new line as `127.0.0.1 <hostName>` at end of file. (hostname is the entry in `cluster/charts/values.yaml`)

10. Finally visit your website on browser by typing the `<hostname>`<br><br>


## Cleanup 

For cleaning up the setup, run <br> 
```
make delete_kind_cluster_with_registry clusterName=<name_of_cluster>
```
(use clusterName provided in *step 4*)

This deletes the entire cluster along with the local registry.