#!/bin/bash

# Parameter check
if [[ $# != 2 ||  $1 = "--help" || $1 = "-h" ]]; then 
    echo Usage: ./mblw.sh artist album
fi


# Check requirements
if ! command -v jq > /dev/null; then
    echo "This script requires jq (https://stedolan.github.io/jq/)"
    exit 1
fi

if ! command -v curl > /dev/null; then
    echo "This script requires curl" 
    exit 1
fi


# Get the album (== release in music brainz)
queryUrl="http://musicbrainz.org/ws/2/release/?query=artist:${1/ /%20}%20AND%20release:${2/ /%20}&fmt=json"

echo Query album data: $queryUrl

releases=$(curl $queryUrl)

releaseId=$(echo $releases | jq '.releases[0].id' -r)

if [ "$releaseId" = "null" ]; then
    echo "Album not found."
    exit 1
fi


# Get the tracks (== recording in music brainz)

trackQueryUrl="http://musicbrainz.org/ws/2/release/$releaseId?inc=artist-credits+recordings&fmt=json"

echo Query album details: $trackQueryUrl

releaseDetails=$(curl $trackQueryUrl)


# Put the data together

artist=$(echo $releases | jq '.releases[0]."artist-credit"[0].artist.name' -r)
if [ $artist = "null" ]; then artist=$1; fi

album=$(echo $releases | jq '.releases[0].title' -r) 
# null should not be possible

releaseYear=$(echo $releases | jq '.releases[0].date' -r)
if [ $releaseYear = "null" ]; then releaseYear=""; fi
if [ ${#releaseYear} > 4 ]; then releaseYear=${releaseYear:0:4}; fi

trackCount=$(echo $releases | jq '.releases[0]."track-count"' -r)
# null should not be possible 

echo "Creating output for $artist $album"

trackList=""
for (( i=0; i<$trackCount; i++ )) do
    trackTitle=$(echo $releaseDetails | jq ".media[0].tracks[$i].title" -r)
    # split in words for capitalization
    trackTitleWords=( $trackTitle )
    # the [@]^ capitalizes every item of the array
    trackList+="# '''[[$artist:${trackTitleWords[@]^}|$trackTitle]]'''"

    artists=$(echo $releaseDetails | jq ".media[0].tracks[$i].recording.\"artist-credit\"[].name" -r)
    
    hasFeatTag=false
    while read -r featArtist; do 
        if [ $artist = $featArtist ]; then continue; fi

        if [ "$hasFeatTag" = false ]; then trackList+=" {{ft"; hasFeatTag=true; fi

        trackList+="|$featArtist"
    done <<< "$artists"

    if [ "$hasFeatTag" = true ]; then trackList+="}}"; fi
    trackList+="\n"
done

albumTitleWords=( $album )

echo -e "########## MAIN PAGE OUTPUT ##########
==[[$artist:${albumTitleWords[@]^} ($releaseYear)|$album ($releaseYear)]]==
{{Album Art||${albumTitleWords[@]^}}}
$trackList{{clear}}
########## MAIN PAGE OUTPUT END ##########"

albumHeader="{{AlbumHeader
|artist    = $artist 
|album     = $album
|genre     = 
|length    =
|cover     =
|wikipedia =
|star      = Green
}}"

albumFooter="{{AlbumFooter
|fLetter     = ${album:0:1}
|asin        =
|iTunes      =
|allmusic    =
|discogs     =
|musicbrainz = $releaseId 
|spotify     =
}}"

echo -e "########## ALBUM PAGE OUTPUT ##########
$albumHeader

$trackList

$albumFooter
########## ALBUM PAGE OUTPUT END ##########"

exit 0

