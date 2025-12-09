FROM ruby:3.2
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 4.0.1
RUN bundle install

COPY . .

EXPOSE 4567
CMD ["bundle", "exec", "puma", "-p", "4567"]

