#!/bin/bash

export PORT=5102
export MIX_ENV=prod
export GIT_PATH=/home/pokemon_crush/src/pokemon_crush

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "pokemon_crush" ]; then
	echo "Error: must run as user 'pokemon_crush'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/pokemon_crush ]; then
	echo mv ~/www/pokemon_crush ~/old/$NOW
	mv ~/www/pokemon_crush ~/old/$NOW
fi

mkdir -p ~/www/pokemon_crush
REL_TAR=~/src/pokemon_crush/_build/prod/rel/pokemon_crush/releases/0.0.1/pokemon_crush.tar.gz
(cd ~/www/pokemon_crush && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/pokemon_crush/src/pokemon_crush/start.sh
CRONTAB

#. start.sh
