FROM postgres:17

# Install required packages for extensions
RUN apt-get update && apt-get install -y \
    postgresql-server-dev-all \
    build-essential \
    git \
    flex \
    bison \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pgvector extension
RUN git clone --branch master --single-branch https://github.com/pgvector/pgvector.git /pgvector \
    && cd /pgvector \
    && make clean \
    && PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config make OPTFLAGS="" \
    && PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config make install \
    && rm -rf /pgvector

# Install AGE extension
RUN git clone --branch release/PG17/1.6.0 --single-branch https://github.com/apache/age.git /age \
    && cd /age \
    && PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config make USE_PGXS=1 \
    && PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config make USE_PGXS=1 install \
    && rm -rf /age

# Copy initialization scripts
COPY init-scripts/01-setup-extensions.sql /docker-entrypoint-initdb.d/01-setup-extensions.sql

# Set the default command to run Postgres
CMD ["postgres"]