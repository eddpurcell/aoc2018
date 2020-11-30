USING: kernel namespaces accessors sets arrays vectors sequences splitting math math.parser regexp ;
USING: io io.files io.encodings.utf8 continuations sorting ;
USE: prettyprint

FROM: namespaces => set ;

IN: time-asm

SYMBOL: r0
SYMBOL: r1
SYMBOL: r2
SYMBOL: r3
SYMBOL: regs
{ r0 r1 r2 r3 } regs set

: set-regs ( init -- ) regs get [ set ] 2each ;
: get-regs ( -- regs ) regs get ;
: get-regs-values ( -- ns ) regs get [ get ] map ;
: get-reg ( n -- reg ) get-regs nth ; inline

: runr ( ...C quot -- ) swap [ [ [ get-reg get ] dip get-reg get ] dip call ] dip ; inline
: runi ( ...C quot -- ) swap [ [ get-reg get ] 2dip call ] dip ; inline
: runir ( ...C quot -- ) swap [ [ get-reg get ] dip call ] dip ; inline

: addr ( A B C -- ) [ + ] runr get-reg set ; inline
: addi ( A B C -- ) [ + ] runi get-reg set ; inline
: mulr ( A B C -- ) [ * ] runr get-reg set ; inline
: muli ( A B C -- ) [ * ] runi get-reg set ; inline
: banr ( A B C -- ) [ bitand ] runr get-reg set ; inline
: bani ( A B C -- ) [ bitand ] runi get-reg set ; inline
: borr ( A B C -- ) [ bitor ] runr get-reg set ; inline
: bori ( A B C -- ) [ bitor ] runi get-reg set ; inline
: setr ( A B C -- ) nip [ get-reg get ] dip get-reg set ; inline
: seti ( A B C -- ) nip get-reg set ; inline
: gtir ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runir get-reg set ; inline
: gtri ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runi get-reg set ; inline
: gtrr ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runr get-reg set ; inline
: eqir ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runir get-reg set ; inline
: eqri ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runi get-reg set ; inline
: eqrr ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runr get-reg set ; inline

TUPLE: sample before after op a b c matching-codes ;
: <sample> ( before after op a b c -- sample ) { } sample boa ;
: sample>args ( sample -- a b c ) dup a>> over b>> rot c>> ;

: run ( A B C word -- ) execute ; inline

: test-sample ( sample ops -- sample' )
  [
    over before>> set-regs
    [ dup sample>args ] dip execute( A B C -- )
    dup after>> get-regs-values =
  ] filter >>matching-codes ;

: parse-registers ( line -- seq ) R/ \d+/ all-matching-subseqs [ string>number ] map ;
: parse-instruction ( line -- op A B C ) " " split [ string>number ] map dup first swap dup second swap dup third swap fourth ;
: parse-sample ( lines -- sample ) dup [ first parse-registers ] dip
                                   dup [ third parse-registers ] dip
                                   second parse-instruction <sample> ;

{ addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr }
800 <vector>

"/Users/edd.purcell/projects/aoc2018/16/samples.txt" utf8 [
  [ 
    [ t ]
    [ readln readln readln readln 4array parse-sample
      pick test-sample over push ] while
  ] ignore-errors
] with-file-reader

! . drop
: part-a ( samples -- n ) [ matching-codes>> length 3 >= ] filter length ;

nip
dup part-a .

: sample>op ( sample -- opCode ) dup op>> swap matching-codes>> 2array ;
: cut-opcode ( sample code op -- ) pick op>> = not [ over matching-codes>> remove >>matching-codes ] [ drop ] if drop ;

dup [ \ borr 0 cut-opcode ] each
dup [ \ addr 1 cut-opcode ] each
dup [ \ eqrr 2 cut-opcode ] each
dup [ \ addi 3 cut-opcode ] each
dup [ \ eqri 4 cut-opcode ] each
dup [ \ eqir 5 cut-opcode ] each
dup [ \ gtri 6 cut-opcode ] each
dup [ \ mulr 7 cut-opcode ] each
dup [ \ setr 8 cut-opcode ] each
dup [ \ gtir 9 cut-opcode ] each
dup [ \ muli 10 cut-opcode ] each
dup [ \ banr 11 cut-opcode ] each
dup [ \ seti 12 cut-opcode ] each
dup [ \ gtrr 13 cut-opcode ] each
dup [ \ bani 14 cut-opcode ] each
dup [ \ bori 15 cut-opcode ] each
[ matching-codes>> length 1 = ] filter [ sample>op ] map members [ first ] sort-with .

{ 0 0 0 0 } set-regs

! ordered opcodes 
{ borr addr eqrr addi eqri eqir gtri mulr setr gtir muli banr seti gtrr bani bori }
"/Users/edd.purcell/projects/aoc2018/16/program.txt" utf8 [
  [ 
    parse-instruction [ over nth ] 3dip roll execute( A B C -- )
get-regs-values .
  ] each-line
  r0 get .
] with-file-reader

drop
