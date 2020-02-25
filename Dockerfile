FROM registry.access.redhat.com/ubi8/ruby-26

#RUN mkdir /app \
# && microdnf install openssl \
# && microdnf clean all

WORKDIR /app
COPY tls-cert-generator /app
