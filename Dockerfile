# Use the official Ruby 2.7.2 image as the base image
FROM ruby:3.0.5 AS build

# Set the working directory to /app
WORKDIR /app

# Copy the Gemfile and Gemfile.lock from the app directory to the container
COPY Gemfile Gemfile.lock ./

# Install the dependencies
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application code to the container
COPY . .

# Build the assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# Remove unneeded files
RUN rm -rf node_modules tmp/cache vendor/bundle test

# Use the official Ruby 2.7.2 image as the base image for the final image
FROM ruby:3.0.5

# Set the working directory to /app
WORKDIR /app

# Copy the Gemfile and Gemfile.lock from the app directory to the container
COPY Gemfile Gemfile.lock ./

# Install the dependencies
RUN bundle install --jobs 4 --retry 3 --without development test

# Copy the rest of the application code to the container
COPY . .

# Copy the precompiled assets from the build image
COPY --from=build /app/public/assets /app/public/assets

# Set the default command to start the server
CMD ["rails", "server", "-b", "0.0.0.0"]
