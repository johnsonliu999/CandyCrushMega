#!/bin/bash

export PORT=5102
export MIX_ENV=prod
export GIT_PATH=/home/candy_crush_mega/src/candy_crush_mega

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "candy_crush_mega" ]; then
	echo "Error: must run as user 'candy_crush_mega'"
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
if [ -d ~/www/candy_crush_mega ]; then
	echo mv ~/www/candy_crush_mega ~/old/$NOW
	mv ~/www/candy_crush_mega ~/old/$NOW
fi

mkdir -p ~/www/candy_crush_mega
REL_TAR=~/src/candy_crush_mega/_build/prod/rel/candy_crush_mega/releases/0.0.1/candy_crush_mega.tar.gz
(cd ~/www/candy_crush_mega && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/candy_crush_mega/src/candy_crush_mega/start.sh
CRONTAB

#. start.sh
