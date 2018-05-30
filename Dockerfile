FROM ubuntu:14.04
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
ENV DISPLAY=':99' \
    CHROME_DRV_VER='2.39' \
    GECKO_DRV_VER='0.20.1' \
    DEBIAN_FRONTEND='noninteractive' \
    CHROME_BIN='/usr/bin/google-chrome' \
    JAVA_HOME='/usr/lib/jvm/java-8-oracle'
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# prepare
RUN apt-get update -y \
 && apt-get install -y wget bash python-pip software-properties-common \
      libappindicator1 fonts-liberation libxi6 libgconf-2-4 unzip libasound2 libnspr4 libnss3 libxss1 xdg-utils \
 && pip install selenium
# jdk8
RUN apt-add-repository -y ppa:webupd8team/java \
 && apt-get update -y
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1   seen true | debconf-set-selections \
 && apt-get install -y oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy
# chrome, driver
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && dpkg -i google-chrome*.deb \
 && wget https://chromedriver.storage.googleapis.com/${CHROME_DRV_VER}/chromedriver_linux64.zip \
 && unzip chromedriver* \
 && mv -f chromedriver /usr/bin/ \
 && rm -rf chromedriver*.zip google-chrome*.deb
# firefox, driver
RUN echo "deb http://ppa.launchpad.net/mozillateam/firefox-next/ubuntu trusty main" \
      > /etc/apt/sources.list.d//mozillateam-firefox-next-trusty.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE49EC21 \
 && apt update -y && apt install -y firefox \
 && wget https://github.com/mozilla/geckodriver/releases/download/v${GECKO_DRV_VER}/geckodriver-v${GECKO_DRV_VER}-linux64.tar.gz \
 && tar -xvzf geckodriver* \
 && mv -f geckodriver /usr/bin/ \
 && chmod +x /usr/bin/geckodriver
# xvfb (1)
RUN apt-get install -y xvfb \
 && touch /usr/bin/start-xvfb \
  && { \
       echo '#!/bin/bash'; \
       echo 'echo "try this Xvfb (1)"'; \
       echo 'Xvfb -ac :99 -screen 0 1280x1024x16 &'; \
     } >> /usr/bin/start-xvfb \
  && chmod +x /usr/bin/start-xvfb
# xvfb (2)
RUN apt-get install -y xvfb \
 && touch /usr/bin/start-xvfb \
  && { \
       echo '#!/bin/bash'; \
       echo 'echo "or try that Xvfb (2)"'; \
       echo '/usr/bin/Xvfb :10 -ac>>/tmp/Xvfb.out &'; \
       echo 'disown -ar'; \
     } >> /usr/bin/start-xvfb \
  && chmod +x /usr/bin/start-xvfb \
CMD /bin/bash
WORKDIR /root/app
ENTRYPOINT /usr/bin/start-xvfb && ./gradlew -Si
COPY . /root/app
# docker build -t tests .
# docker run --rm --name run-tests -v ~/.gradle:/root/.gradle -v ~/.m2:/root/.m2 tests
