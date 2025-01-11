# Build stage
FROM ubuntu:latest AS builder

ENV DEBIAN_FRONTEND=noninteractive

ADD ./ /tmp/asm3

# Install only the packages needed for building
RUN apt-get update && apt-get install -y \
    make \
    git \
    dpkg-dev

WORKDIR /tmp/asm3
RUN make version

WORKDIR /tmp/asm3/install/deb
RUN ./makedeb.sh

# Runtime stage
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-wsgi-py3 \
    python3 \
    python3-pil \
    python3-webpy \
    python3-mysqldb \
    python3-psycopg2 \
    imagemagick \
    wkhtmltopdf \
    python3-reportlab \
    python3-requests \
    python3-boto3 \
    memcached \
    python3-memcache \
    python3-xhtml2pdf \
    python3-lxml \
    && rm -rf /var/lib/apt/lists/*

# Copy the built .deb file from builder
COPY --from=builder /tmp/asm3/install/deb/sheltermanager3_*_all.deb /tmp/

# Install the package
RUN dpkg -i /tmp/sheltermanager3_*_all.deb && \
    rm /tmp/sheltermanager3_*_all.deb

# Configure Apache
RUN a2enmod wsgi && a2ensite asm3 && service apache2 restart

# Verify configuration
RUN apache2ctl -t

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]