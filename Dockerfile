FROM daggerok/e2e-ubuntu-jdk8-xvfb
LABEL MAINTAINER='Maksim Kostromin https://github.com/daggerok/selenide-in-docker'
USER e2e
RUN echo '#!/bin/bash \n\
\#we need this huck, because we wanna reuse existing ~/.m2 and ~/.gradle folders... \n\
sudo mkdir -p mkdir -p /home/e2e/.gradle/caches/modules-2/files-2.1 /home/e2e/.m2/repository \n\
sudo chown -R e2e:e2e /home/e2e/.gradle /home/e2e/.m2 \n\
sudo exec runuser -u e2e start-xvfb \n\
sudo exec runuser -u e2e "$@" \n' > /home/e2e/entrypoint.sh \
 && sudo mv -f /home/e2e/entrypoint.sh /usr/bin/
WORKDIR /home/e2e/selenide-in-docker
CMD /bin/bash
ENTRYPOINT entrypoint.sh "\
./gradlew -Si check chrome \
&& ./gradlew -Si clean test firefox
#ENTRYPOINT start-xvfb \
#             && sudo chown -R e2e:e2e ~/ \
#             && ./gradlew -Si check chrome \
#             && ./gradlew -Si clean test firefox
COPY --chown=e2e . .
