FROM debian:wheezy

ADD https://get.docker.com/ /tmp/get-docker.sh
ADD https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker /usr/local/bin/wrapdocker

RUN apt-get update  && \
    # install packages
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates lxc iptables git make openssh-server openjdk-7-jre-headless sudo && \
    mkdir -p /var/run/sshd && \
    bash /tmp/get-docker.sh && \
    # install docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    # clean temp files
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # make wrapdocker, forego and docker-compose executable
    chmod +x /usr/local/bin/wrapdocker && \
    chmod +x /usr/local/bin/docker-compose && \
    # patch wrapdocker to always exit after setup
    sed -i 's/# otherwise, spawn a shell as well/exit 0/g' /usr/local/bin/wrapdocker && \
    # add jenkins user
    useradd -U -m -s /bin/bash -G docker jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    echo "jenkins  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

VOLUME /var/lib/docker

ADD start.sh /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
