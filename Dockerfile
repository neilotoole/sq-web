# Build stage - install dependencies and build the site
# Using Debian-based image because Hugo extended requires glibc (not musl/Alpine)
FROM oven/bun:1-debian AS builder

# Hugo version to install (should match package.json otherDependencies.hugo)
ARG HUGO_VERSION=0.122.0

# Base URL for the site (default for local Docker testing)
ARG BASE_URL=http://localhost:8080/

# Install Go (required for Hugo modules), C++ libs (required for Hugo extended),
# and download Hugo directly to avoid exec-bin wrapper issues
RUN apt-get update && apt-get install -y --no-install-recommends \
    golang-go \
    git \
    ca-certificates \
    curl \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/* \
    && ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${ARCH}.tar.gz" \
       | tar -xz -C /usr/local/bin hugo \
    && hugo version \
    && ln -s /usr/local/bin/bun /usr/local/bin/npx

WORKDIR /app

# Copy package files first for better caching
COPY package.json bun.lock* ./

# Install dependencies (skip postinstall since we installed Hugo manually)
RUN bun install --ignore-scripts

# Copy the rest of the project
COPY . .

# Build the site using Hugo directly with the specified base URL
RUN hugo --gc --minify --baseURL "${BASE_URL}" && \
    cat static/_redirects >> public/_redirects

# Production stage - serve static files with nginx
FROM nginx:alpine AS runner

# Copy the built static site
COPY --from=builder /app/public /usr/share/nginx/html

# Copy custom nginx config if needed
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

