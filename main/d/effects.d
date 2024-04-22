module effects;

immutable wstring[] text_for_typing = [
//   0123456789012345
    "-Алло,это ВПЧ-2?",
    "-Да.",
    "-Что у вас там", "горит?",
    "-Взрыв на главн-",
    "ом корпусе! 3-й,",
    "4-й, между 3 и", "4 блоком.",
    "А там люди есть?",
    "-Да! Подымай ",
    "начсостав!",
    "-Подымаю. На-",
    "чальника поднял!",
    "-Так всех,всех,",
    "весь офицерский",
    "состав,офицер-",
    "ский корпус", "подымай!",
];

size_t waitBetweenLines;
private size_t curr_letter;
private size_t curr_line;

void step()
{
    if(waitBetweenLines > 0)
        waitBetweenLines--;
    else
        curr_letter++;

    if(curr_letter >= text_for_typing[curr_line].length)
    {
        waitBetweenLines = 20;
        curr_letter = 0;
        curr_line++;
    }
}

wstring getCurrState(out size_t lastLetter)
{
    lastLetter = curr_letter < 16 ? curr_letter : 15;

    auto s = text_for_typing[curr_line];
    return s[0 .. lastLetter];
}
