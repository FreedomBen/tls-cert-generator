FROM registry.access.redhat.com/ubi8/ruby-26

ENV TLS_CERT_GENERATOR_VERSION 0.0.1

#Set the images labels.
LABEL io.k8s.description="Generates TLS certs for use in testing/debugging" \
  io.k8s.display-name="TLS Cert Generator (${TLS_CERT_GENERATOR_VERSION})" \
  io.openshift.tags="tls,mtls" \
  name="tls-cert-generator" \
  architecture="x86_64" \
  maintainer="FreedomBen"

USER root
RUN mkdir /opt/app-root/bin /opt/app-root/generated \
 && chown 1001:0 -R /opt/app-root \
 && dnf install openssl \
 && dnf clean all

COPY --chown=1001:0 Gemfile /opt/app-root/src/
WORKDIR /opt/app-root/src

RUN bundle install

USER default
COPY --chown=1001:0 tls-cert-generator /opt/app-root/bin/

WORKDIR /opt/app-root/generated
CMD ["/opt/app-root/bin/tls-cert-generator"]
