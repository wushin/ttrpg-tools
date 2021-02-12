FROM node:14

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
RUN mkdir -p /usr/src/build/
RUN mkdir -p /usr/src/app/
COPY ./code/ /usr/src/build/
RUN chown node:node -R /usr/src/build/
RUN chown node:node -R /usr/src/app/

USER node
WORKDIR /usr/src/build

RUN npm install -g serve

RUN npm install

RUN npm run build

RUN mkdir -p /usr/src/app/build-tmp/ && cp -a ./build/* /usr/src/app/build-tmp/
RUN cp -a ./public /usr/src/app/
RUN cp -a ./node_modules /usr/src/app/
RUN cp -a ./package.json /usr/src/app/
RUN cp -a ./package-lock.json /usr/src/app/
VOLUME ["/usr/src/app/build"]
EXPOSE 3000
