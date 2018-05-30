FROM ubuntu:14.04
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
ENV DISPLAY=':99' \
    CHROME_DRV_VER='2.39' \
    GECKO_DRV_VER='0.20.1' \
    DEBIAN_FRONTEND='noninteractive' \
    CHROME_BIN='/usr/bin/google-chrome' \
    JAVA_HOME='/usr/lib/jvm/java-8-oracle'
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# for some reasons chrome cannot run from root user anymore, so lets create new one (e2e)
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
 && sudo apt-get install -y wget bash python-pip software-properties-common \
      libappindicator1 fonts-liberation libxi6 libgconf-2-4 unzip \
      libasound2 libnspr4 libnss3 libxss1 xdg-utils \
 && sudo pip install selenium
# jdk8
RUN sudo apt-add-repository -y ppa:webupd8team/java \
 && sudo apt-get update -y \
 && sudo echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
 && sudo echo debconf shared/accepted-oracle-license-v1-1   seen true | sudo debconf-set-selections \
 && sudo apt-get install -y oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy
# chrome, driver
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && sudo dpkg -i google-chrome*.deb \
 && wget https://chromedriver.storage.googleapis.com/${CHROME_DRV_VER}/chromedriver_linux64.zip \
 && unzip chromedriver* \
 && sudo mv -f chromedriver /usr/bin/ \
 && rm -rf chromedriver*.zip google-chrome*.deb
# firefox, driver
RUN sudo sudo add-apt-repository ppa:mozillateam/firefox-next \
 && sudo apt update -y \
 && sudo apt install -y firefox \
 && wget https://github.com/mozilla/geckodriver/releases/download/v${GECKO_DRV_VER}/geckodriver-v${GECKO_DRV_VER}-linux64.tar.gz \
 && tar -xvzf geckodriver* \
 && sudo mv -f geckodriver /usr/bin/ \
 && sudo chmod +x /usr/bin/geckodriver
# xvfb (1)
RUN sudo apt-get install -y xvfb \
 && echo '#!/bin/bash \n\
echo "try this Xvfb (1)" \n\
sudo Xvfb -ac :99 -screen 0 1280x1024x16 & \n' \
      >> ./start-xvfb \
 && sudo chmod +x ./start-xvfb \
 && sudo mv -f ./start-xvfb /usr/bin/start-xvfb \
 && sudo cat /usr/bin/start-xvfb
# xvfb (2)
RUN sudo apt-get install -y xvfb \
 && echo '#!/bin/bash \n\
echo "or try that Xvfb (2)" \n\
/usr/bin/Xvfb :10 -ac>>/tmp/Xvfb.out & \n' \
      >> ./start-xvfb \
 && sudo cat ./start-xvfb >> /usr/bin/start-xvfb \
 && sudo cat /usr/bin/start-xvfb
CMD /bin/bash
ENTRYPOINT sudo chown -R e2e:e2e ./ib6-gdpr/ && . /usr/bin/start-xvfb && cd ./ib6-gdpr/ && ./gradlew -Si
COPY . /home/e2e/ib6-gdpr
# docker build -t tests .
# docker run --rm --name run-tests -v ~/.gradle:/home/e2e/.gradle -v ~/.m2:/home/e2e/.m2 tests
