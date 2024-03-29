# ====
# Dockerfile para ambiente de desenvolvimento
# ====
FROM ruby:3.2-alpine3.17 as ruby

ARG APP_PATH=/app
ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_USER_UID=1000
ARG APP_GROUP_GID=1000

RUN apk add --update bash openssh git tzdata curl less && \
    apk add --update --no-cache --virtual .build-deps \
       build-base \
       libxml2-dev libxslt-dev

# rubygems 3.4.6 provides bundler 2.3.8
RUN gem update --system "3.4.6"

# user handling
RUN addgroup -g $APP_GROUP_GID -S $APP_GROUP && \
    adduser -S -s /sbin/nologin -u $APP_USER_UID -G $APP_GROUP $APP_USER && \
    mkdir $APP_PATH && \
    chown $APP_USER:$APP_GROUP $APP_PATH

# creating volumes with user ownership
# XXX: @see https://github.com/docker/compose/issues/3270#issuecomment-206214034
RUN mkdir -p $APP_PATH/vendor/bundle && chown $APP_USER:$APP_GROUP -R $APP_PATH
VOLUME $APP_PATH/vendor

USER $APP_USER

# add ssh credentials on build
# - if you define SSH_KEY build arg, it'll be used preferentially
# - if you have keys defined in ".docker/.ssh/" dir, they'll be used (`id_rsa`)
ARG SSH_KEY=""
RUN mkdir /home/$APP_USER/.ssh/
# XXX: using * instead of "id_rsa" to make it "optional"
# @see https://stackoverflow.com/a/46801962
COPY --chown=$APP_USER:$APP_GROUP .docker/.ssh/.keep .docker/.ssh/id_rsa* /home/$APP_USER/.ssh/
RUN if [ "$SSH_KEY" != "" ]; then \
      echo "SSH_KEY build arg being used"; \
      echo "${SSH_KEY}" > /home/$APP_USER/.ssh/id_rsa; \
    fi
RUN chmod 0700 /home/$APP_USER/.ssh && \
    chmod 0400 /home/$APP_USER/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /home/$APP_USER/.ssh/known_hosts && \
  ssh-keyscan github.com >> /home/$APP_USER/.ssh/known_hosts

WORKDIR $APP_PATH

# Copy source and install dependencies
COPY --chown=$APP_USER:$APP_GROUP . $APP_PATH
RUN bundle config path "vendor/bundle" && \
  bundle install --jobs 4 --retry 3


# CMD ["bundle", "exec", "guard"]
CMD ["bash"]
