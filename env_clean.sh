#!/bin/bash

ssh_Username=$1
dst_dir=$2

if [ "$ssh_Username"X == X ] || [ "$dst_dir"X == X ]
then 
        echo "the variable is not exitsted!!"
        exit 2
fi
sudo mkdir -p $dst_dir
sudo rm -rf $dst_dir/*
mkdir -p /home/$ssh_Username/$dst_dir
rm -rf /home/$ssh_Username/$dst_dir/*
