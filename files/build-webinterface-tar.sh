#!/bin/bash

find . -name *.pyc -exec rm -rv {} \;
echo 'yes' | ./webinterface/manage.py collectstatic
tar czvf webinterface.tar.gz webinterface/
