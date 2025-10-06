FROM postgres:16

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    postgresql-server-dev-16 \
    && rm -rf /var/lib/apt/lists/*

# Download and install pg_roaringbitmap
RUN wget https://github.com/RoaringBitmap/pg_roaringbitmap/archive/refs/heads/master.tar.gz -O /tmp/pg_rb.tar.gz \
    && tar -xzf /tmp/pg_rb.tar.gz -C /tmp/ \
    && cd /tmp/pg_roaringbitmap-master \
    && make && make install \
    && rm -rf /tmp/pg_rb.tar.gz /tmp/pg_roaringbitmap-master

# Remove build dependencies to keep image light
RUN apt-get remove -y build-essential postgresql-server-dev-16 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt
