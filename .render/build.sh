#!/bin/bash

set -e

echo "Instalando gems"
bundle install

echo "Precompilando assets"
bundle exec rake assets:precompile

echo "Ejecutando migraciones"
bundle exec rails db:migrate

echo "Ejecutando seeds"
bundle exec rails db:seed
