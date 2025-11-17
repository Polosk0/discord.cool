#!/bin/bash
# Script wrapper pour démarrer le bot
cd "$(dirname "$0")"
exec node_modules/.bin/tsx src/index.ts

