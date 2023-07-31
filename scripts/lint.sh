#!/bin/bash

pass=0
guides=$(ls docs/移植手册)
for file in $guides;
do
    file=docs/移植手册/$file

    ## 标题不以 # 开头，或含有 - 或非小写字母以外的符号
    head -n 1 $file | grep -n -v -e '^# [0-9a-z\-]*$'
    if [ $? -eq 0 ]; then
        pass=1
        echo "$file"
    fi
done

if [ $pass -eq 1 ]; then
    exit 1
fi
