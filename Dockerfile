FROM daggerok/e2e-ubuntu-jdk8-xvfb
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
WORKDIR /home/e2e/selenide-in-docker
USER e2e
CMD /bin/bash
ENTRYPOINT start-xvfb \
             && ls -lah ~/ \
             && ls -lah ~/selenide-in-docker/ \
             && ./gradlew -Si check chrome \
             && ./gradlew -Si clean test firefox
#ENTRYPOINT start-xvfb \
#             && sudo chown -R e2e:e2e ~/ \
#             && ./gradlew -Si check chrome \
#             && ./gradlew -Si clean test firefox
COPY --chown=e2e . .
