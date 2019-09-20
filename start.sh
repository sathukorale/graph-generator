#!/bin/bash

screen -dm bash -c " node --max-http-header-size=80000 index.js" -S nodejs-graph-generator
