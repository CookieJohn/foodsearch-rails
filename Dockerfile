FROM ubuntu:18.04

FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /foodsearch
WORKDIR /foodsearch

COPY Gemfile /foodsearch/Gemfile
COPY Gemfile.lock /foodsearch/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . /foodsearch
