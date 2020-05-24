FROM openjdk:11.0.7-jre

WORKDIR /home/

RUN wget https://download2.interactivebrokers.com/portal/clientportal.gw.zip

RUN unzip clientportal.gw.zip && rm clientportal.gw.zip

COPY conf.yaml /home/root/conf.yaml
COPY generateCert.sh /home/generateCert.sh

EXPOSE 5000

CMD ./generateCert.sh && bin/run.sh root/conf.yaml
