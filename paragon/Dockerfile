FROM node:14

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

WORKDIR /usr/src/build

RUN npm install -g serve

COPY ./code/ .

RUN npm install

RUN npm run build

RUN mkdir -p /usr/src/app/build-tmp/ && cp -a ./build/* /usr/src/app/build-tmp/
RUN cp -a ./public /usr/src/app/
RUN cp -a ./node_modules /usr/src/app/
RUN cp -a ./package.json /usr/src/app/
RUN cp -a ./package-lock.json /usr/src/app/
