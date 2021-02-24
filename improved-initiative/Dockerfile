FROM node:14
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin
RUN mkdir -p /usr/src/app/
COPY ./code/ /usr/src/app/
RUN chown node:node -R /usr/src/app/

USER node
WORKDIR /usr/src/app
RUN npm install -g grunt
RUN npm install
RUN grunt --no-color copy
RUN grunt --no-color build_dev
VOLUME ["/usr/src/app/public"]
EXPOSE 4000
