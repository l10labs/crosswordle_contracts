const MIN_LETTER: u8 = 'A';
const MAX_LETTER: u8 = 'Z';

mod errors {
    const WORD_NOT_5_CHARS: felt252 = 0;
    const CHAR_NOT_A_LETTER: felt252 = 1;
}

pub fn assert_five_letter_word(word_byte_array: @ByteArray) {
    let word_length = word_byte_array.len();
    assert(word_length == 5, errors::WORD_NOT_5_CHARS);

    let mut i = 0;
    while i < 5 {
        assert(
            word_byte_array[i] >= MIN_LETTER && word_byte_array[i] <= MAX_LETTER,
            errors::CHAR_NOT_A_LETTER
        );
        i += 1;
    };
}
