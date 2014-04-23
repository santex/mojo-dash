#!/usr/bin/bash

x=$(mojo get -r "https://www.bitcoin.de/en?cr=1" ".fright.pt5 strong" text | tr -d "€")

echo $x;

echo "insert into BTCtoEURO (priceInEuro) values ("$x")" | mysql -u root -ppass btc;
