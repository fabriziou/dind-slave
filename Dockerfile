FROM debian:wheezy

ADD https://get.docker.com/ /tmp/get-docker.sh
ADD https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego /usr/local/bin/forego
ADD https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker /usr/local/bin/wrapdocker
ADD Procfile /etc/Procfile

RUN apt-get update  && \
    # install packages
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates lxc iptables git make openssh-server openjdk-7-jre-headless && \
    mkdir -p /var/run/sshd && \
    bash /tmp/get-docker.sh && \
    # install docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    # clean temp files
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # make wrapdocker, forego and docker-compose executable
    chmod +x /usr/local/bin/wrapdocker && \
    chmod +x /usr/local/bin/forego && \
    chmod +x /usr/local/bin/docker-compose && \
    # patch wrapdocker to always start docker daemon in foreground
    sed -i 's/# otherwise, spawn a shell as well/exec docker -d $DOCKER_DAEMON_ARGS/g' /usr/local/bin/wrapdocker && \
    # add jenkins user
    useradd -U -m -s /bin/bash -G docker jenkins && \
    echo "jenkins:jenkins" | chpasswd

VOLUME /var/lib/docker

CMD ["forego", "start", "-f", "/etc/Procfile", "-r"]
