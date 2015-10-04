# Musicbrainz to LyricWiki 

A very simple shell script to get album data from [MusicBrainz](https://musicbrainz.org/), 
format it for [LyricWiki](http://lyrics.wikia.com/wiki) and print it to the standart output.

Usage:

./mblw.sh album artist

```
./mblw.sh Radiohead "ok computer"
```

This script does not do any magic, tell it exactly what you want (the correct artist and album have to be provided).
It may fail badly in edge cases, there is not much checking going on, use at your own risk.

Only tested with Linux.


## Requirements

- jq (https://stedolan.github.io/jq/ - a very awsome lightweight command-line JSON processor)
- curl

## Thanks to

- bash
- curl
- jq 
- LyricWiki
- MusicBrainz

## License

Licensed under MIT-license, see LICENSE
