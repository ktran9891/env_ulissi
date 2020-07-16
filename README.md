The Ulissi group has a moderate Docker swarm of desktops/GPUs available for data science and ML development.
This repository is an example of how you can use this Docker swarm for daily development.
It has two helpful services:
* an ssh daemon that you can SSH into to use as a personal development environment
* a GPU-enabled Jupyter server with the standard ASE/pymatgen/etc packages

but you are welcome to try other things!

# Setup instructions to use the Docker swarm
1. Ask Zack to make an account you at the Portainer interface to the Docker swarm. Also ask him to reserve both an ssh port and a Jupyter port.
2. Fork this repository
3. Update the [`Dockerfile`](./Dockerfile) 
    * Edit the line `ARG USERNAME=*` in Dockerfile to your Portainer username
    * Edit the "user-specific configurations" section to whatever you want. You can leave it blank for a minimal image.
4. Update the [`jupyter/Dockerfile`](./jupyter/Dockerfile) the same way you modified the root `Dockerfile`.
    * Note the [`start-notebook.sh`](./jupyter/start-notebook.sh) script. You may also need to modify/remove the configurable settings in that script, depending on how you configure the image.
5. Add your ssh public key to `default_authorized_keys`
    * If you're unsure what your public key is, make one with `ssh-keygen -t rsa -b 4096`, then copy the line in your `~/.ssh/id_rsa.pub` to replace the line in `default_authorized_keys`
6. Build and push your two images to [DockerHub](https://hub.docker.com/)
    * If you're unsure how to build and push Docker images, ask fellow group members and/or follow tutorials on [building](https://docs.docker.com/get-started/part2/) and [pushing](https://docs.docker.com/get-started/part3/) Docker images.
7. Update the [`docker-compose.yml`](./docker-compose.yml) file by replacing the corresponding contents on each line
    * The `services.ssh.image` argument should point to the image you built from the root [`Dockerfile`](./Dockerfile) in this repository.
    * The `services.ssh.ports.published` argument should be populated with the ssh port number Zack reserved for you.
    * The `services.jupyter.image` argument should point to the image you built from the Jupyter [`Dockerfile`](./jupyter/Dockerfile) in this repository.
    * The `services.jupyter.ports.published` argument should be populated with the Jupyter port number Zack reserved for you.
8. Start your stack
    * Go to [Portainer](http://laikapack.cheme.cmu.edu:9000)
    * Click on the "Stacks" menu in the sidebar
    * Click on "+ Add Stack"; make a stack name\*; copy your updated [`docker-compose.yml`](./docker-compose.yml) into the web editor, then deploy!

\* Save this stack name!
If you want to mount back to the some folder system later, you must access it using the same exact stack name.

# Access
That's it!
You have both an ssh account and a Jupyter notebook that should stay alive.
They will both have access to your home folder on the host you specified in the `services.*.deploy.placement.constraints.node.hostname` argument of the [`docker-compose.yml`](./docker-compose.yml) file.
The home folder will be mounted to the `/home/volume` folder in the Docker container, which means that *any files you save outside of this `/home/volume` folder will be deleted if you close the container/stack!*
* You will have a permanent ssh shell you can access via:  `ssh -p $YOUR_SSH_PORT $USERNAME@laikapack.cheme.cmu.edu`
* You will have a Jupyter server at the website:  `http://laikapack.cheme.cmu.edu:$YOUR_JUPYTER_PORT`
The Jupyter server may ask you for a token.
You can find the token by doing the following:
    * Go to [Portainer](http://laikapack.cheme.cmu.edu:9000).
    * Click on "Stacks" on the left.
    * Click on the stack you created.
    * Click on `stack_name_jupyter`.
    * Scroll to the bottom and under the `Tasks` section, find the running Jupyter task. Then clik on the "logs" button under the "Action" column.
    * You should see the `stdout` of the container, which should include the Jupyter token.

<!--
# Adding services
You can add services by going to your stack, clicking editor, and deploying a new service. For example, 
-->
