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

# Install maven 
ARG MAVEN_VERSION=3.3.9
ARG USER_HOME_DIR="/root"
ARG SHA1=5b4c117854921b527ab6190615f9435da730ba05

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz https://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
  && echo "${SHA1}  /tmp/apache-maven.tar.gz" | sha1sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

VOLUME "$USER_HOME_DIR/.m2"

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

	
