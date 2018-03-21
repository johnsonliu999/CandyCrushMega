#!/bin/bash

export PORT=5102

cd ~/www/pokemon_crush
./bin/pokemon_crush stop || true
./bin/pokemon_crush start
