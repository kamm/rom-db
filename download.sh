#!/bin/bash

platform=$1

if [ $# -ne 1 ]; then
    echo "Give me platform name :) "
    exit 1
fi

rm -f log.txt
wget -q -O - http://www.freeroms.com/${platform}.htm | grep -i href | grep ">[\#A-Z]<" | perl -pe 's|.*"(.*)".*|\1|' |
while read letterurl; do
    letter=`echo $letterurl | sed s/.*_// | sed s/.htm//`
    echo $letter
    mkdir -p ${platform}/$letter
    wget -q -O - http://www.freeroms.com/${platform}_roms_${letter}.htm | 
        grep game_id | 
        grep dl_roms |
        sed \
            -e "s/.*http:\/\/www.freeroms.com\/dl_roms/http:\/\/www.freeroms.com\/dl_roms/g" \
            -e "s/\".*//" | 
        while read url; do
            params=`echo $url | sed s/.*\\?//`
        
            title=`echo $params | perl -pe 's|title.||' | cut -d\& -f1`
            gameid=`echo $params | perl -pe 's|.*game_id.||'`
            x=`wget -q -O - "http://www.freeroms.com/rom/${platform}/${title}.htm" | grep mirror1.freeroms.com`
            game_title=`wget -q -O - "http://www.freeroms.com/rom/${platform}/${title}.htm" | grep itemprop..name | sed "s/<.td.*//" | sed s/.*nowrap.//`
            baseurl=`echo $x | perl -pe 's|.*?http|http|' | sed 's/".*//'`
            basename=`echo $x | perl -pe 's|"http.*?"||g' | perl -pe 's|.*"(.*?)".*|\1|'`
        
            if [[ $baseurl == */ ]]; then
                url=${baseurl}${basename}
            else
                url=${baseurl}/${basename}
            fi
        
            wget  -q -O ${platform}/$letter/${gameid}_${basename} $url
            a=$?
            if [ $a -ne 0 ]; then
                echo $a $url
            fi
        
            echo ${gameid}";"$letter/${gameid}_${basename}";"${game_title} >>${platform}/log.txt
    done
done        
        
