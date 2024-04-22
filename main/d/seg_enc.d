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

immutable uint[] numbers =
[
    a|d|f|e|b|c|j|k,    //0
    a1|i|l|d,           //1
    a|b|g|e|d,          //2
    a|b|g|c|d,          //3
    f|g|b|c,            //4
    a|f|g|c|d,          //5
    a|f|g|c|d|e,        //6
    a|j|l,              //7
    a|d|f|e|b|c|g,      //8
    a|d|f|b|c|g,        //9
];

immutable uint[] latin =
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

immutable uint[] cyrillic =
[
    k|j|g2|b|c,         //А
    a|f|e|d|g1|m,       //Б
    a|d|f|e|j|c|g,      //В
    a|f|e,              //Г
    a|d|f|e|b|c|dpl|dpr,//Д
    a|f|e|d|g1,         //Е
    h|m|i|l|j|k,        //Ж
    a|j|g2|c|d,         //З
    f|e|k|j|b|c,        //И
    f|e|k|j|b|c|i,      //Й
    f|e|g1|j|m,         //К
    k|j|b|c,            //Л
    f|e|b|c|h|j,        //М
    f|e|g|b|c,          //Н
    f|e|b|c|a|d,        //О
    f|e|a|b|c,          //П
    a|f|e|g|b,          //Р
    a|d|f|e,            //С
    a|i|l,              //Т
    f|d|g|b|c,          //У
    a|f|i|b|g|l,        //Ф
    h|m|k|j,            //Х
    f|e|d|b|c|dpr,      //Ц
    h|g2|b|c,           //Ч
    f|e|i|l|b|c|d,      //Ш
    f|e|i|l|b|c|d|dpr,  //Щ
    a1|i|l|g2|c|d2,     //Ъ
    f|e|d1|l|g1|b|c,    //Ы
    f|g1|m|d|e,         //Ь
    a|b|g2|c|d,         //Э
    f|e|g1|i|l|a2|d2|b|c,   //Ю
    a|f|b|c|g|k,        //Я
];

uint utf2seg(in wchar c) pure
{
    uint ret;

    if(c == 0x0020) // space;
    {
    }
    else if(c >= 0x0030 && c <= 0x0039)
        ret = numbers[c - 0x0030];
    else if(c >= 0x0041 && c <= 0x005a)
        ret = latin[c - 0x0041];
    else if(c >= 0x0061 && c <= 0x007a) //TODO: implement lowercase chars table
        ret = latin[c - 0x0061];
    else if(c >= 0x0410 && c <= 0x422f)
        ret = cyrillic[c - 0x0410];
    else if(c == 0x0401) // Cyrillic "Ё" spicial case
        ret = cyrillic[5]; // "Е"
    //~ else
        //~ ret = 0b01111111_00101010; // unknown symbol marking (cross in square)

    return ret;
}
