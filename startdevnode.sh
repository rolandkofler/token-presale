#!/usr/bin/env bash
geth --dev --password <(echo ) account new 
geth --dev --rpc --rpccorsdomain "*"  --unlock 0 --password <(echo ) --mine
