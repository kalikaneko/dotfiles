import json
import commands

with open('songs.json') as f:
    info = f.read()

songs = json.loads(info)


def removeUnicode(text):
    if(isinstance(text, str)):
        return str.decode('utf-8').encode("ascii", "ignore")
    else:
        return text.encode("ascii", "ignore")


for i, song in enumerate(songs):
    title = song['title'].replace(' ', '_').replace('/', '')
    url = "http:" + song['file']['mp3-128']
    path = "%02d_%s.mp3" % (i + 1, title)
    path = removeUnicode(path)
    print "PATH", path, type(path)
    print "Downloading ", url, "-->", path
    print commands.getoutput('wget "%s" -O %s' % (url, path))
