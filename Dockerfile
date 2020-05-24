FROM blueimp/chromedriver

USER root

# https://github.com/debuerreotype/docker-debian-artifacts/issues/24
RUN mkdir -p /usr/share/man/man1

# Install JRE
RUN apt update && apt install -y openjdk-11-jre-headless unzip && rm -rf /var/lib/apt/lists/*

USER webdriver

WORKDIR /home/webdriver/

# Install Gateway
RUN wget https://download2.interactivebrokers.com/portal/clientportal.gw.zip && \
    unzip clientportal.gw.zip && rm clientportal.gw.zip

COPY conf.yaml /home/webdriver/root/conf.yaml
COPY generateCert.sh /home/webdriver/generateCert.sh

EXPOSE 5000

ENTRYPOINT ./generateCert.sh && bin/run.sh root/conf.yaml
CMD ""
