FROM daggerok/e2e-ubuntu-jdk8-xvfb:all
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
WORKDIR 'selenide-in-docker/'
CMD /bin/bash
ENTRYPOINT start-xvfb && ./gradlew -Si check firefox
COPY --chown=e2e . .
