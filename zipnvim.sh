#!/usr/bin/env bash

# zipnvim.sh

# Created: 11/09/26
# To create nvim copy for codex

# vim: set nospell:

cd ~/.config/nvim/

rm nvim.zip

zip -r nvim.zip lua skeletons ftplugin init.lua nvim-pack-lock.json

echo

zip --test nvim.zip
