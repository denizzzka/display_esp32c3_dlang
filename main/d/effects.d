module effects;

immutable wstring[] text_for_typing = [
//   0123456789012345
    "-Алло,это ВПЧ-2?", null,
    "-Да.", null,
    "-Что у вас там", "горит?", null,
    "-Взрыв на главн-",
    "ом корпусе! 3-й,",
    "4-й, между 3 и", "4 блоком.", null,
    "А там люди есть?", null,
    "-Да! Подымай ",
    "начсостав!", null,
    "-Подымаю. На-",
    "чальника поднял!", null,
    "-Так всех,всех,",
    "весь офицерский",
    "состав,офицер-",
    "ский корпус", "подымай!", null,
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
        curr_letter = 0;
        curr_line++;

        if(text_for_typing[curr_line] is null)
        {
            curr_line++;
            waitBetweenLines = 30;
        }
    }
}

wstring getCurrState(out size_t lastLetter)
{
    lastLetter = curr_letter < 16 ? curr_letter : 15;

    auto s = text_for_typing[curr_line];
    return s[0 .. lastLetter+1];
}
