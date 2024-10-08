# ================================
# Build image
# ================================
FROM swift:latest

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Run the tests
RUN swift test

# Build everything, with optimizations, with static linking, and using jemalloc
RUN swift build -c release --static-swift-stdlib
