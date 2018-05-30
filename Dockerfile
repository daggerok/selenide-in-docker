FROM ubuntu:14.04
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
ENV DISPLAY=':99' \
    GECKO_DRV_VER='0.20.1' \
    DEBIAN_FRONTEND='noninteractive' \
    JAVA_HOME='/usr/lib/jvm/java-8-oracle'
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# e2e user with sudo will executex tests
USER root
RUN apt update \
 && apt install -y htop sudo openssh-server vim \
 && useradd -m e2e && echo "e2e:e2e" | chpasswd \
 && adduser e2e sudo \
 && echo "\ne2e ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && service ssh restart
USER e2e
WORKDIR /home/e2e
# prepare
RUN sudo apt-get update -y \
 && sudo apt-get install -y wget bash software-properties-common
# jdk8
RUN sudo apt-add-repository -y ppa:webupd8team/java \
 && sudo apt-get update -y \
 && sudo echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
 && sudo echo debconf shared/accepted-oracle-license-v1-1   seen true | sudo debconf-set-selections \
 && sudo apt-get install -y oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy
# firefox
RUN sudo add-apt-repository ppa:mozillateam/firefox-next \
 && sudo apt-get update -y \
 && sudo apt-get install -y firefox
# gecko driver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v${GECKO_DRV_VER}/geckodriver-v${GECKO_DRV_VER}-linux64.tar.gz \
 && tar -xvzf geckodriver* \
 && sudo mv -f geckodriver /usr/bin/ \
 && sudo chmod +x /usr/bin/geckodriver
# xvfb stuff
RUN sudo apt-get install -y xvfb xorg xvfb dbus-x11 xfonts-100dpi xfonts-75dpi xfonts-cyrillic \
 && echo '#!/bin/bash \n\
echo "starting Xvfb..." \n\
sudo Xvfb -ac :99 -screen 0 1280x1024x16 & \n' \
      >> ./start-xvfb \
 && chmod +x ./start-xvfb \
 && sudo mv -f ./start-xvfb /usr/bin/start-xvfb

CMD /bin/bash
ENTRYPOINT sudo chown -R e2e:e2e ./selenide-in-docker && . /usr/bin/start-xvfb && cd ./selenide-in-docker && ./gradlew -Si check firefox
#ENTRYPOINT sudo chown -R e2e:e2e ./selenide-in-docker && . /usr/bin/start-xvfb && cd ./selenide-in-docker && ./gradlew -Si check headless firefox
COPY . ./selenide-in-docker

## usage:
# docker build -t tests .
# docker run --rm --name run-tests -v ~/.gradle:/home/e2e/.gradle -v ~/.m2:/home/e2e/.m2 tests
