FROM daggerok/e2e-ubuntu-jdk8-xvfb
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
WORKDIR /home/e2e/selenide-in-docker
USER e2e
CMD /bin/bash
ENTRYPOINT start-xvfb \
             && ./gradlew -Si check chrome \
             && ./gradlew -Si clean test firefox
COPY --chown=e2e . .
