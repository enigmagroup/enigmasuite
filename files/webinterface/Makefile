all:
	clear
	./manage.py syncdb
	./manage.py migrate app
	./manage.py runserver

trans:
	./manage.py makemessages -l de

compiletrans:
	./manage.py compilemessages

.PHONY: all
