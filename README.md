### Docker image

The `Dockerfile` and accompanying `build.sh` and `run.sh` scripts enable building and running a Docker image that encapsulates Shiny, the Bowtie 2 UI and their dependencies.  `build.sh` builds the image, which is based on the [`rocker/shiny` image](https://hub.docker.com/r/rocker/shiny/).  `run.sh` runs the container in daemon mode, mapping port 3838 on localhost to 3838 on the Shiny appliance.  After `run.sh`, you should be able to navigate to http://localhost:3838/bt2-ui and see the UI.

### Launching with Vagrant

The `Vagrantfile` in the root directory allows you to launch an EC2 instance, install Bowtie 2, install several Bowtie 2 indexes from the wonderful [AWS-iGenomes](https://ewels.github.io/AWS-iGenomes/) resource, and pull & run the Docker image at `benlangmead/bt2-ui`.

Prerequisites:
* Vagrant
* The `vagrant-aws` plugin (`vagrant plugin install vagrant-aws`)
* An AWS account with appropriate privileges and credentials files
* A Docker Hub account with appropriate credentials files

You should edit `Vagrantfile` to reflect:
* The location of your credentials files
* An EC2 security group under your AWS account that allows inbounds SSH and web connections
* An appropriate subnet under your AWS account

To launch:
* `vagrant up` in root directory

To see UI:
* Wait for launching to complete
* Navigate to `http://<ec2-public-ip>/bt2-ui`

To destroy:
* `vagrant destroy` in root directory

### TODO

The Docker image has the Shiny app "baked in", but not the Bowtie 2 software or genome indexes.  We need to come up with a policy for where the Shiny looks to find them, so that we can supply them to the app via Docker mounts.  The `docker run` command in the `Vagrantfile` currently mounts the indexes to `/indexes` and the Bowtie 2 software to `/software` within the container, but the app doesn't know to look in those places yet.
