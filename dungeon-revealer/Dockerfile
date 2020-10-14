FROM node:12-alpine as base
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# add build tools for other architectures
# subsequent builds should cache this layer
RUN apk add make g++ python

FROM base as dependency-builder
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

WORKDIR /usr/src/build

RUN echo "unsafe-perm = true" > .npmrc

COPY ./code/ .

RUN npm install

FROM dependency-builder as application-builder
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

ARG SKIP_BUILD

RUN if [ "$SKIP_BUILD" = "true" ]; then echo "SKIP BUILD"; else npm run build; fi

FROM dependency-builder as production-dependency-builder

# then we remove all dependencies we no longer need
RUN npm prune --production

FROM node:12-alpine as final
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# Create app directory
WORKDIR /usr/src/app

# Copy app source
COPY --from=application-builder /usr/src/build/build /usr/src/app/build-tmp
COPY --from=application-builder /usr/src/build/server-build /usr/src/app/server-build
COPY --from=production-dependency-builder /usr/src/build/node_modules /usr/src/app/node_modules
COPY --from=production-dependency-builder  /usr/src/build/package.json /usr/src/app/package.json
COPY --from=production-dependency-builder  /usr/src/build/package-lock.json /usr/src/app/package-lock.json

ARG NODE_ENV="production"
ENV NODE_ENV="production"
