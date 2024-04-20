module seg_enc;

/*
       a1       a2
     ------- -------
    | \     |     / |
   f|  \h   |i  j/  |b
    |   \   |   /   |
    | g1 \  |  / g2 |
     ------- -------
    |    /  |  \    |
   e|   /   |   \   |c
    |  /k   |l  m\  |
    | /     |     \ |
     ------- -------
  |    d1       d2    |
  |dpl                |dpr

*/

enum a1  = 0b_0000_0000_0000_0000_0000_0001;
enum a2  = 0b_0000_0000_0000_0100_0000_0000;
enum b   = 0b_0000_0000_0000_0010_0000_0000;
enum c   = 0b_0000_0000_0000_0001_0000_0000;
enum d1  = 0b_0000_1000_0000_0000_0000_0000;
enum d2  = 0b_1000_0000_0000_0000_0000_0000;
enum e   = 0b_0000_0100_0000_0000_0000_0000;
enum f   = 0b_0000_0000_0000_0000_0000_0010;
enum g1  = 0b_0000_0000_1000_0000_0000_0000;
enum g2  = 0b_0000_0000_0000_1000_0000_0000;
enum h   = 0b_0000_0000_0100_0000_0000_0000;
enum i   = 0b_0000_0000_0010_0000_0000_0000;
enum j   = 0b_0000_0000_0001_0000_0000_0000;
enum k   = 0b_0001_0000_0000_0000_0000_0000;
enum l   = 0b_0010_0000_0000_0000_0000_0000;
enum m   = 0b_0100_0000_0000_0000_0000_0000;
enum dpl = 0b_0000_0000_0000_0000_0000_0100;
enum dpr = 0b_0000_0000_0000_0000_0000_1000;

enum a = a1|a2;
enum d = d1|d2;
enum g = g1|g2;

immutable uint[] latin_abc =
[
    k|j|g2|b|c,         //A
    a|d|i|l|b|c|g2,     //B
    a|d|f|e,            //C
    a|d|i|l|b|c,        //D
    a|d|f|e|g1,         //E
    a|f|e|g1,           //F
    a|d|f|e|c|g2,       //G
    f|e|g|b|c,          //H
    a|d|i|l,            //I
    b|c|d|e,            //J
    f|e|g1|j|m,         //K
    f|e|d,              //L
    f|e|b|c|h|j,        //M
    f|e|b|c|h|m,        //N
    f|e|b|c|a|d,        //O
    a|f|e|g|b,          //P
    f|e|b|c|a|d|m,      //Q
    a|f|e|g|b|m,        //R
    a|d|h|g2|c,         //S
    a|i|l,              //T
    f|e|d|b|c,          //U
    f|e|k|j,            //V
    f|e|b|c|k|m,        //W
    h|m|k|j,            //X
    h|j|l,              //Y
    a|d|k|j,            //Z
];