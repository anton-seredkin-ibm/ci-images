FROM registry.access.redhat.com/ubi9/toolbox:latest

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install Java 21, Maven, curl, unzip, tar, gzip for Gradle and Docker CLI
RUN dnf -y install java-21-openjdk maven curl unzip tar gzip && \
    dnf clean all

# Install Docker CLI (static)
ARG DOCKER_VERSION=29.2.1
RUN case "$(uname -m)" in \
      x86_64) DOCKER_ARCH=x86_64 ;; \
      aarch64) DOCKER_ARCH=aarch64 ;; \
      *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz" && \
    tar -xzf /tmp/docker.tgz -C /tmp && \
    install -m 0755 /tmp/docker/docker /usr/local/bin/docker && \
    rm -rf /tmp/docker /tmp/docker.tgz

# Install Gradle
ARG GRADLE_VERSION=8.14.3
RUN curl -fsSL -o /tmp/gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
    unzip -q /tmp/gradle.zip -d /opt && \
    ln -s "/opt/gradle-${GRADLE_VERSION}" /opt/gradle && \
    rm -f /tmp/gradle.zip

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-21.0.10.0.7-1.el9.x86_64
ENV PATH="/opt/gradle/bin:${JAVA_HOME}/bin:${PATH}"
