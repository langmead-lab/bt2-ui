#!/bin/sh

if [ $# -lt 2 ]; then
   echo "Usage: $0 target_directory source_directory ..."
   exit 1
fi

target_dir="$1"
shift

if [ ! -d $target_dir ]; then
    mkdir -p $target_dir;
fi

for d in $@; do
    if [ ! -d $d ]; then
        continue
    fi

    for f in $d/*; do
        file_name=$( basename $f )
        index_name=${file_name%%.*}
        dest="$target_dir/$index_name"
        if [ ! -e $dest ]; then
            mkdir $dest || (echo "Cannot create directory $dest" && exit 1)
        fi

        ext=${f#*.}
        cp $f $dest/genome.$ext
    done
done