# fdo-server
RHEL + Go FDO server and systemd units to start instance of fdo manufacturing, rendezvous and owner servers


## Build AMI 
Pull image 

```sh
sudo podman pull $REGISTRY/$REGISTRY_USER$/fdo-server:aws
```

Use BiB to build AMI image

```sh
sudo podman pull $REGISTRY/$REGISTRY_USER/fdo-server:aws

sudo podman run \
--authfile=$PULL_SECRET \
--rm \
--privileged \
--security-opt label=type:unconfined_t \
-v $HOME/.aws:/root/.aws:ro \
--env AWS_PROFILE=default \
-v /var/lib/containers/storage:/var/lib/containers/storage \
registry.redhat.io/rhel9/bootc-image-builder:latest \
--type ami \
--aws-ami-name fdo-server-x86_64 \
--aws-bucket bootc-amis \
--aws-region us-west-2 \
$REGISTRY/$REGISTRY_USER/fdo-server:aws
```