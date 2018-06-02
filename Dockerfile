FROM daggerok/e2e-ubuntu-jdk8-xvfb:chrome
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
WORKDIR 'selenide-in-docker/'
CMD /bin/bash
ENTRYPOINT start-xvfb \
             && ./gradlew -Si check chrome
#ENTRYPOINT start-xvfb \
#             && ./gradlew -Si check chrome \
#             && ./gradlew -Si clean test firefox
COPY --chown=e2e . .
