#!/usr/bin/env python
from sys import argv
from bs4 import BeautifulSoup
import urllib
import urllib2

if len(argv) < 2:
    raise ValueError("You must supply a url")
if len(argv) > 2:
    raise ValueError("Too many command line arguments")

try:
    params = urllib.urlencode({'url' : argv[1]})
    req = urllib2.Request('http://tx0.org', params)
except urllib2.HTTPError, e:
    print "HTTP Error: %d" % e.code
except urllib2.URLError, e:
    print "Network error: %s" % e.reason.args[1]

#Hacky webscrape! :O
soup = BeautifulSoup(urllib2.urlopen(req).read())
results = soup.findAll("td", {"bgcolor" : "CCCCCC"})
if len(results) < 1:
    print "tx0.org didn't return a short url. Did you format it correctly?"
    quit
for result in results:
    if len(result.attrs) == 1:
        print result.text
