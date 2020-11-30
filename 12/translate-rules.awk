BEGIN {
  FS=" => "
}

{
  printf "0 5 \"%s\" <slice> \"%s\" <rule> 1array append\n", $1, $2
}
