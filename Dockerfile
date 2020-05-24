FROM openjdk:11.0.7-jre

WORKDIR /home/

RUN wget https://download2.interactivebrokers.com/portal/clientportal.gw.zip

RUN unzip clientportal.gw.zip && rm clientportal.gw.zip

EXPOSE 5000

CMD bin/run.sh root/conf.yaml
