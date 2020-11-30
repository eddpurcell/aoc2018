USING: kernel sequences arrays splitting regexp math accessors ;
USING: io.files io.encodings.utf8 ;
USE: prettyprint

IN: elf-directions

: flatten ( seq -- seq' ) { } [ dup array? [ ] [ 1array ] if append ] reduce ;
: ?flatten ( seq -- seq' ) dup first array? [ flatten ] [ ] if ;

: expand-branch ( prefixes str -- seq ) "|" split cartesian-product { } [ append ] reduce [ concat ] map ;
: (potential-group-markers) ( str -- slices ) R/ \|/ [ [ drop 0 ] 2dip <slice> ] map-matches ;
: (#char) ( char str -- n ) [ over = [ 1 ] [ 0 ] if ] map-sum nip ;
: (#() ( str -- n ) [ CHAR: ( ] dip (#char) ; 
: (#)) ( str -- n ) [ CHAR: ) ] dip (#char) ;
: (marker-for-group?) ( slice -- ? ) [ (#() ] keep (#)) - 0 = ;
: split-branches ( str -- seq ) dup (potential-group-markers) [ (marker-for-group?) ] filter [ to>> 1 - ] map split-indices unclip 1array [ [ rest ] map ] dip append ;
: f>"" ( str/f -- str/"" ) dup [ ] [ drop "" ] if ;
: prefix ( str -- presuf branches ) "(" split1 [ 1 ] dip [ dup CHAR: ( = [ drop [ 1 + ] dip f ] [ CHAR: ) = [ [ 1 - ] dip over 0 = [ t ] [ f ] if ] [ f ] if ] if ] split1-when [ drop ] 2dip swap [ 2array ] dip f>"" ;
: expand? ( str -- ? ) [ CHAR: ( = ] find drop ;
: expand-regexp ( str -- seq ) prefix split-branches 
  [ dup expand? [ expand-regexp ] [ 1array ] if ] map flatten 
  [ over first swap append ] map
  swap second dup expand? [ expand-regexp ] [ 1array ] if cartesian-product flatten [ [ first ] [ second ] bi append ] map ;

: cycle? ( str -- ? ) [ CHAR: N over (#char) [ CHAR: S swap (#char) ] dip - 0 = ] [ CHAR: E over (#char) [ CHAR: W swap (#char) ] dip - 0 = ] bi and ;
: invert-slice ( slice -- seq ) [ [ from>> ] [ seq>> ] bi 0 -rot <slice> ] [ [ to>> ] [ seq>> length ] [ seq>> ] tri <slice> ] bi append ;
: >slices ( str n -- slices ) [ [ length ] dip - 1 + <iota> ] 2keep rot [ pick [ over over + ] dip <slice> ] map 2nip ;
: update-slice ( seq slice -- slice ) [ seq>> length swap length - ] 2keep rot [ [ from>> ] dip - ] [ [ to>> ] dip - ] 2bi rot <slice> ;
: (remove-cycles) ( seq n -- seq' ) dupd >slices [ cycle? ] filter [ dup empty? ] [ nip unclip invert-slice swap [ dupd update-slice ] map ] until drop ;
: remove-cycles ( seq -- seq' ) dup length 2 - <iota> <reversed> [ (remove-cycles) ] each ;

"/Users/edd.purcell/projects/aoc2018/20/input-clean.txt" utf8 file-contents but-last expand-regexp [ remove-cycles length ] map supremum .
! "WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))" expand-regexp [ remove-cycles length ] map supremum .
