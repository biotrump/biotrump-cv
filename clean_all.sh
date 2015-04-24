#!/bin/bash
repo forall -vc "git reset --hard"
repo forall -vc "git clean -f -d"
