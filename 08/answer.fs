USING: kernel io io.files io.encodings.utf8 math math.parser sequences ;
USING: prettyprint arrays accessors ;

IN: license-scheme
TUPLE: node { children sequence } { meta sequence } ;
: <node> ( -- node ) node new ;

: read-int-token ( -- n ) " " read-until drop string>number ;
: read-counts ( -- n-children n-meta ) read-int-token read-int-token ;

: read-meta ( n -- seq ) 0 <array> [ drop read-int-token ] map ;
: read-node ( -- node ) <node> read-counts [ 
  <node> <array> [ drop read-node ] map >>children
] dip read-meta >>meta ;

: get-all-metas ( node -- seq ) dup meta>> swap children>> [ get-all-metas append ] each ;

: ind>nodes ( nodes indices -- nodes ) [ 1 - ] map [ over bounds-check? ] filter swap nths ;
: get-node-value ( node -- n ) dup children>> empty? 
  [ meta>> sum ]
  [ dup children>> swap meta>> ind>nodes [ get-node-value ] map sum ] if ;

"input.txt" utf8 [ read-node dup get-all-metas sum . get-node-value . ] with-file-reader
