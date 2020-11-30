USING: vectors math math.order kernel assocs sequences accessors namespaces prettyprint regexp math.parser io io.files io.encodings.utf8 ;

IN: guard-rotation
TUPLE: sleep-interval start stop ;
: <sleep-interval> ( -- sleep-interval ) sleep-interval new ;
: total-time ( sleep-interval -- n ) dup stop>> swap start>> - ;
: sum-time ( sleep-intervals -- n ) [ total-time ] map sum ;
: interval>seq ( sleep-interval -- seq ) dup stop>> swap start>> tuck - <iota> [ over + ] map nip ;
: intervals>minmap ( sleep-intervals -- assoc ) 60 H{ } new-assoc swap [ interval>seq [ over inc-at ] each ] each ;
: most-common-time ( assoc -- n ) dup values supremum swap value-at ;

: guard? ( str -- ? ) R/ .*Guard.*/ matches? ;
: str>guard-id ( str -- n ) R/ #\d+/ first-match CHAR: # swap remove string>number ;

: asleep? ( str -- ? ) R/ .*falls asleep/ matches? ;
: wakeup? ( str -- ? ) R/ .*wakes up/ matches? ;
: str>minute ( str -- n ) R/ :\d{2}/ first-match CHAR: : swap remove string>number ;

: at-or ( exemplar key assoc -- val/exemplar ) at dup [ nip ] [ drop ] if ;

SYMBOL: guards

H{ } guards set

"sorted-input.txt" utf8 [
  readln
  [
    str>guard-id dup [ 100 <vector> swap guards get at-or ] dip swap ! ( guard-id intervals )
    [
      readln dup f = not [ dup asleep?
        [ <sleep-interval> swap str>minute >>start readln str>minute >>stop over push t ] 
        [ [ swap guards get set-at ] dip f ] if
      ] [ [ swap guards get set-at ] dip f ] if
    ] loop
    dup
  ] loop
  drop
] with-file-reader

guards get H{ } assoc-clone-like dup keys [ 2dup swap at sum-time swap pick set-at ] each dup values supremum swap value-at 
dup guards get at intervals>minmap most-common-time * .

guards get harvest-values dup keys [ 2dup swap at intervals>minmap values supremum swap pick set-at ] each dup values supremum swap value-at dup guards get at intervals>minmap most-common-time * .

