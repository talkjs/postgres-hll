# Define a build argument for the PostgreSQL version
ARG POSTGRES_VERSION

# Use the specified PostgreSQL version as the base image
FROM postgres:${POSTGRES_VERSION}

# Install the required dependencies for the HLL extension
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        postgresql-server-dev-${POSTGRES_VERSION%%.*} \
        git \
        ca-certificates \
        wget

# Clone the HLL extension repository
RUN git clone https://github.com/citusdata/postgresql-hll.git

# Build and install the HLL extension
RUN cd postgresql-hll && \
    make && \
    make install

# Clean up the build dependencies
RUN apt-get remove -y \
        build-essential \
        postgresql-server-dev-${POSTGRES_VERSION%%.*} \
        git \
        ca-certificates \
        wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /postgresql-hll

# Add the HLL extension creation command to the initialization script
RUN echo "CREATE EXTENSION hll;" > /docker-entrypoint-initdb.d/enable_hll_extension.sql
