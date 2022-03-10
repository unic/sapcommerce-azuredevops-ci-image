FROM lennartjuetteunic/sapcommerce-build-image:20220310140707

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

## Install Azure CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu66 \
    libunwind8 \
    netcat \
    libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

## Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
  && rm -rf /var/lib/apt/lists/*

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

## Basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
  && rm -rf /var/lib/apt/lists/*

ENV TARGETARCH=linux-x64
ENV JAVA_HOME_11_X64=$JAVA_HOME
WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
