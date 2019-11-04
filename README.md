#packra.pl

_packing randomness_

it takes ranges of characters as arguments (FROM TO FROM TO ...)

it calculates how many possible values are there of them

on stdin it takes [0;255] bytes, takes a module of each and returns it as character from ranges

the rest it divides by the possible value count and uses it for return of another character

so, `./packra.pl 0 9 A F` should give you a little-endian-by-digits hexadecimal encoder
 — pipe `dd bs=1 count=3 if=/dev/urandom` to it to get a **random color in hex notation**

and for generating a **random** _text file_ composed of Polish latin2 characters, we can use

```bash
dd bs=1 count=100 if=/dev/urandom |
./packra.pl " " "~" $'\n' $'\n' $'\xA0' $'\xA1' \
$'\xA3' $'\xA3' $'\xA6' $'\xA7' $'\xAC' $'\xAD' $'\xAF' $'\xB1' \
$'\xB3' $'\xB3' $'\xB6' $'\xB6' $'\xBC' $'\xBC' $'\xBF' $'\xBF' \
$'\xC6' $'\xC6' $'\xCA' $'\xCA' $'\xD1' $'\xD1' $'\xD3' $'\xD3' $'\xD7' $'\xD7' \
$'\xE6' $'\xE6' $'\xEA' $'\xEA' $'\xF1' $'\xF1' $'\xF3' $'\xF3' $'\xF7' $'\xF7'
```
