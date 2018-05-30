FROM ubuntu:14.04
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
ENV DISPLAY=':99' \
    DEBIAN_FRONTEND='noninteractive' \
    CHROME_BIN='/usr/bin/google-chrome' \
    JAVA_HOME='/usr/lib/jvm/java-8-oracle'
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN apt-get update -y \
 && apt-get install -y wget bash software-properties-common \
 && apt-add-repository -y ppa:webupd8team/java \
 && apt-get update -y
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1   seen true | debconf-set-selections \
 && apt-get install -y \
      oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy
RUN apt-get install -y \
      xvfb libappindicator1 fonts-liberation libxi6 libgconf-2-4 unzip \
      libasound2 libnspr4 libnss3 libxss1 xdg-utils \
 && wget https://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip \
 && unzip chromedriver* \
 && mv -f chromedriver /usr/bin/ \
 && rm -rf chromedriver*.zip \
 && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && dpkg -i google-chrome*.deb \
 && rm -rf *.deb
RUN touch /usr/bin/docker-entrypoint \
 && { \
      echo '#!/bin/bash'; \
      echo '#sh -e /etc/init.d/xvfb start'; \
      echo 'Xvfb -ac :99 -screen 0 1280x1024x16 &'; \
    } > /usr/bin/docker-entrypoint \
 && chmod +x /usr/bin/docker-entrypoint
CMD /bin/bash
WORKDIR /root/app
ENTRYPOINT /usr/bin/docker-entrypoint && ./gradlew -Si clean check
COPY . /root/app
