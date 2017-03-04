#!/bin/bash

bundle exec rake api:update && \
bundle exec rake api:validate && \
git add . && \
git commit -m "Automatic update at `date`" && \
git push origin master
