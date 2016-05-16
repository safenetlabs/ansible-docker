FROM alpine:3.3
RUN apk update
RUN apk add --update openssh py-pip build-base libffi-dev python-dev openssl-dev \
    && pip install --upgrade pip \
    && pip install ansible \
    && apk del --purge build-base libffi-dev python-dev openssl-dev \
    && rm -rf /var/cache/apk/**/
ENV PATH /root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN ln -s /dev/null /root/.ash_history