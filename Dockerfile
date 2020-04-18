FROM maven:3.6.3-jdk-8-slim

ARG APP_PATH='./simple-java-maven-app'

COPY ${APP_PATH} /usr/app/

CMD ["/usr/app/jenkins/scripts/deliver.sh"]
