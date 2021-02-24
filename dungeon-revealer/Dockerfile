FROM node:14 as base
# add build tools for other architectures
# subsequent builds should cache this layer
RUN apt-get update && apt-get install -y make g++ python

FROM base as dependency-builder
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

WORKDIR /usr/src/build

COPY ./code/ /usr/src/build/

RUN echo "unsafe-perm = true" > .npmrc

RUN npm install

FROM dependency-builder as application-builder
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

ARG SKIP_BUILD

RUN if [ "$SKIP_BUILD" = "true" ]; then echo "SKIP BUILD"; else npm run build; fi

FROM dependency-builder as production-dependency-builder
# then we remove all dependencies we no longer need
RUN npm prune --production

FROM node:14 as final
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# Create app directory
WORKDIR /usr/src/app

# Copy app source
COPY --from=application-builder /usr/src/build/build /usr/src/app/build
COPY --from=application-builder /usr/src/build/server-build /usr/src/app/server-build
COPY --from=production-dependency-builder /usr/src/build/node_modules /usr/src/app/node_modules
COPY --from=production-dependency-builder  /usr/src/build/package.json /usr/src/app/package.json
COPY --from=production-dependency-builder  /usr/src/build/package-lock.json /usr/src/app/package-lock.json

RUN chown node:node -R /usr/src/app/
USER node
RUN mkdir /usr/src/app/build-export/

ARG NODE_ENV="production"
ENV NODE_ENV="production"
EXPOSE 3000
CMD ["node", "server-build/index.js"]
