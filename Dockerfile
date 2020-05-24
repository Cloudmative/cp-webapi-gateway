FROM blueimp/chromedriver

USER root

# Drop dependency to X11
RUN sed -i '${s/$/'" --headless"'/}' /opt/google/chrome/google-chrome

# https://github.com/debuerreotype/docker-debian-artifacts/issues/24
RUN mkdir -p /usr/share/man/man1

# Install JRE, unzip, jq
RUN apt update && apt install -y openjdk-11-jre-headless unzip jq && rm -rf /var/lib/apt/lists/*

USER webdriver

WORKDIR /home/webdriver/

# Install Gateway
RUN wget https://download2.interactivebrokers.com/portal/clientportal.gw.zip && \
    unzip clientportal.gw.zip && rm clientportal.gw.zip

COPY conf.yaml /home/webdriver/root/conf.yaml
COPY generateCert.sh /home/webdriver/generateCert.sh
COPY magic.sh /home/webdriver/magic.sh

EXPOSE 5000

ENTRYPOINT ./generateCert.sh && chromedriver --port=4444 --whitelisted-ips & bin/run.sh root/conf.yaml & sleep 7; while true; do ./magic.sh; sleep 60; done
CMD ""
