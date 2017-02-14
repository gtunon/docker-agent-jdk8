FROM ubuntu:14.04
MAINTAINER Guiomar Tuñon <gtunon@naevatec.com>

RUN apt-get update &&\
	apt-get install -y openssh-server curl &&\
	apt-get clean -y && rm -rf /var/lib/apt/lists/* &&\ 
	sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
	mkdir -p /var/run/sshd
	
RUN adduser --quiet jenkins &&\
    echo "jenkins:jenkins" | chpasswd
	
RUN curl -fsSL https://get.docker.com/ | sh

# Install Java.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	add-apt-repository -y ppa:webupd8team/java && \
	apt-get update && \
	apt-get install -y oracle-java8-installer && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


	
