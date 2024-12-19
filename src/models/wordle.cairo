use crosswordle::models::index::Wordle;

const MIN_LETTER: u8 = 'A';
const MAX_LETTER: u8 = 'Z';

mod errors {
    const WORD_NOT_5_CHARS: felt252 = 0;
    const CHAR_NOT_A_LETTER: felt252 = 1;
}

#[generate_trait]
impl WordleImpl of WordleTrait {
    fn new(id: felt252, word_byte_array: @ByteArray) -> Wordle {
        assert_five_letter_word(word_byte_array);

        let l1 = word_byte_array[0];
        let l2 = word_byte_array[1];
        let l3 = word_byte_array[2];
        let l4 = word_byte_array[3];
        let l5 = word_byte_array[4];
        Wordle { id, l1, l2, l3, l4, l5 }
    }
}

fn assert_five_letter_word(word_byte_array: @ByteArray) {
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

#[cfg(test)]
mod tests {
    use super::{WordleImpl, assert_five_letter_word};
    use crosswordle::models::index::Wordle;

    #[test]
    fn test_pass_wordle_new() {
        let wordle = WordleImpl::new(0, @"NINJA");
        let manual_wordle: (u8, u8, u8, u8, u8) = ('N', 'I', 'N', 'J', 'A');
        assert_eq!((wordle.l1, wordle.l2, wordle.l3, wordle.l4, wordle.l5), manual_wordle);
    }

    #[test]
    #[should_panic(expected: 0)]
    fn test_fail_not_five_letters() {
        WordleImpl::new(0, @"AAA");
    }

    #[test]
    #[should_panic(expected: 1)]
    fn test_fail_not_letters() {
        WordleImpl::new(0, @"1A2B3");
    }
}
