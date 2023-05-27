ARG sapmachine_version
FROM sapmachine:$sapmachine_version

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Install basic utilities & packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        curl \
        procps \
        xz-utils \
        git \
        ssh \
    && rm -rf /var/lib/apt/lists/*

# Install mariadb for test that require a real DBMS
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && curl -o chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y --no-install-recommends ./chrome.deb\
    && rm ./chrome.deb \
    && rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN=/usr/bin/google-chrome-stable

## Install Azure CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu70 \
    libunwind8 \
    netcat \
    libssl3 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

## Install Maven
RUN curl 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.2/apache-maven-3.9.2-bin.tar.gz' -o - |tar -zxv -C /opt \
    && ln -s "$(find  /opt/ -iname 'apache-maven-*')" "/opt/apache-maven"

ENV PATH="${PATH}:/opt/apache-maven/bin"


## Install Docker
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update && apt-get install -y --no-install-recommends \
    docker-ce-cli \
  && rm -rf /var/lib/apt/lists/*

## Install basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
  && rm -rf /var/lib/apt/lists/*

## Install BATS
RUN apt-get update && apt-get install -y --no-install-recommends \
    bats \
  && rm -rf /var/lib/apt/lists/*

## Install outdated libssl1.1 as dependency for azure agent
RUN curl http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -o /tmp/libssl.dpkg \
  && dpkg -i /tmp/libssl.dpkg \
  && rm /tmp/libssl.dpkg



ENV TARGETARCH=linux-x64
ENV JAVA_HOME_17_X64=$JAVA_HOME
WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
