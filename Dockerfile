FROM ubuntu:14.04
MAINTAINER Guiomar Tuñon <gtunon@naevatec.com>

# Set up ssh server
EXPOSE 22
RUN apt-get update &&\
	apt-get install -y openssh-server curl \
	# Required to not get a 'Missing privilege separation directory' error
        && mkdir /var/run/sshd \
	&& ssh-keygen -A \
	&& sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
	 && echo "DONE *****************************************************"

RUN curl -fsSL https://get.docker.com/ | sh

RUN apt-get install -y software-properties-common

# Install Java.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	add-apt-repository -y ppa:webupd8team/java && \
	apt-get update && \
	apt-get install -y oracle-java8-installer && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Set up some environment for SSH clients (ENV statements have no affect on ssh clients)
RUN echo "export DOCKER_HOST='unix:///var/run/docker.sock'" >> /root/.bashrc \
 && echo "export DEBIAN_FRONTEND=noninteractive" >> /root/.bashrc

RUN cp -a /etc/ssh/ /etc/ssh.original/ \
 && cp -a /etc/pam.d/ /etc/pam.d.original/



# use a volume for the SSH host keys, to allow a persistent host ID across container restarts
VOLUME ["/etc/ssh/ssh_host_keys"]
 
# Set user jenkins to the image
RUN adduser --quiet jenkins &&\
    echo "jenkins:jenkins" | chpasswd

USER jenkins

RUN cd ~/ &&\
        echo "$USER" && \
        pwd

CMD ["/usr/sbin/sshd", "-D"]

	
