use crosswordle::models::index::Wordle;
use crosswordle::helpers::validity::assert_five_letter_word;

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

#[cfg(test)]
mod tests {
    use super::WordleImpl;
    use crosswordle::models::index::Wordle;
    use crosswordle::helpers::validity::assert_five_letter_word;

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
