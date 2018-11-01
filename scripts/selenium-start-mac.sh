#!/usr/bin/env bash

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )


if [ -z $( which java ) ]
then
    brew tap caskroom/cask
    brew tap caskroom/versions
    brew cask install java7
fi

mkdir -p $BASEDIR/selenium
cd $BASEDIR/selenium

if [[ ! -f selenium-server-standalone-3.8.0.jar ]]
then
    wget http://selenium-release.storage.googleapis.com/3.8/selenium-server-standalone-3.8.0.jar
fi

if [[ ! -f chromedriver ]]
then
    CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`
    wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_mac64.zip
    unzip chromedriver_mac64.zip
    rm chromedriver_mac64.zip
fi
java -jar -Dwebdriver.chrome.driver=chromedriver $BASEDIR/selenium/selenium-server-standalone-3.8.0.jar

#DISPLAY=:1 xvfb-run java -jar ~/selenium/selenium-server-standalone-2.44.0.jar