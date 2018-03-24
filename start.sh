#!/bin/bash

export PORT=5102

cd ~/www/candy_crush_mega
./bin/candy_crush_mega stop || true
./bin/candy_crush_mega start
