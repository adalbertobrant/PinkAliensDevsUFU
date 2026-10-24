FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  git

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Compilar a extensão C++ (motor de regras).
# O `|| true` evita que a build falhe caso a compilação não seja possível;
# nesse caso o Rails usa o modo de compatibilidade (Ruby puro).
RUN cd ext/antecipe_core && ruby extconf.rb && make 2>&1 || true

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
