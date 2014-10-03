#!/usr/bin/env python
import sqlite3, requests, json
import sys, os
from time import sleep

class Addressbook:

    def __init__(self):
        self.database = '/etc/enigmabox/addressbook.db'
        self.directory = 'http://directory'
        self.db = sqlite3.connect(self.database)
        self.db.text_factory = sqlite3.OptimizedUnicode
        self.init_db()

    def init_db(self):
        try:
            c = self.db.cursor()
            c.execute("""CREATE TABLE addresses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ipv6 TEXT,
            hostname TEXT,
            phone INTEGER
            )""")
        except Exception:
            pass

    def import_addresses(self):
        c = self.db.cursor()

        request_tries = 100
        while request_tries > 0:

            print 'trying to fetch addressbook.csv...'

            try:
                r = requests.get(self.directory + '/addressbook.csv', timeout=10)
                print 'success!'
                request_tries = 0

            except Exception:
                print 'failed. ' + str(request_tries) + ' more tries to go'

            request_tries -= 1
            sleep(1)

        if r.text:
            c.execute("DELETE FROM addresses")

        for line in r.text.split('\n'):
            print line

            try:
                l = line.split(',')
                c.execute("INSERT INTO addresses(ipv6,hostname,phone) VALUES(?,?,?)", [l[0], l[1], l[2]])

            except Exception:
                print 'record skipped, probably empty'

        self.db.commit()

        self.set_option('config_changed', '1')

    def post_address(self):
        global_address_status = self.get_option('global_address_status')

        if global_address_status == 'pending':
            global_hostname = self.get_option('global_hostname')
            global_phone = self.get_option('global_phone')
            print 'status pending, hostname: ' + global_hostname + ', phone: ' + global_phone + '.'

            if global_hostname == '' and global_phone == '':
                print 'unsetting...'

                data = self.post_to_directory(self.directory + ':16909/unset_address')

                if data['msg'] == 'OK':
                    self.set_option('global_address_status', 'unset')

            else:
                print 'publishing address...'

                data = self.post_to_directory(self.directory + ':16909/set_address', {
                    'hostname': global_hostname,
                    'phone': global_phone,
                })

                if data['msg'] == 'OK':
                    self.set_option('global_address_status', 'confirmed')

                elif data['msg'] == 'error':
                    self.set_option('global_address_status', 'rejected')

            print 'done.'

    def post_to_directory(self, url, post_params = False):

        request_tries = 100
        while request_tries > 0:

            print 'trying to post...'

            try:
                if post_params:
                    resp = requests.post(url, post_params, timeout=10).text
                else:
                    resp = requests.post(url, timeout=10).text

                print 'success!'
                return json.loads(resp)

            except Exception:
                print 'failed. ' + str(request_tries) + ' more tries to go'

            request_tries -= 1
            sleep(1)

    def get_option(self, key):

        try:
            resp = requests.post('http://127.0.0.1:8000/api/v1/get_option', {
                'key': key,
            }).text
            data = json.loads(resp)
            return data['value']

        except Exception:
            print 'error in getting ' + key
            return False

    def set_option(self, key, value):

        try:
            resp = requests.post('http://127.0.0.1:8000/api/v1/set_option', {
                'key': key,
                'value': value,
            }).text
            data = json.loads(resp)
            return data['result']

        except Exception:
            print 'error in setting ' + key + ' to ' + value
            return False



a = Addressbook()

if len(sys.argv) >= 2 and sys.argv[1] == 'push':
    a.post_address()

if len(sys.argv) >= 2 and sys.argv[1] == 'pull':
    if len(sys.argv) >= 3 and sys.argv[2] == 'now':
        pass
    else:
        print 'sleeping...'
        from random import randint
        sleep(randint(1, 999))
    a.import_addresses()

