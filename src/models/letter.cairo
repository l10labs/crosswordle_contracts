use crosswordle::models::index::Letter;

#[generate_trait]
impl LetterImpl of LetterTrait {
    #[inline]
    fn new(id: felt252, value: felt252) -> Letter {
        LetterAssert::assert_is_valid_letter(value);
        Letter { id: id, value: value }
    }
}

mod errors {
    const LETTER_NOT_VALID: felt252 = 'Letter: not valid';
}

#[generate_trait]
impl LetterAssert of AssertTrait {
    #[inline]
    fn assert_is_valid_letter(self: felt252) {
        let letter_value: u32 = self.try_into().unwrap();
        assert(letter_value >= LETTER_A && letter_value <= LETTER_Z, errors::LETTER_NOT_VALID);
    }
}

const LETTER_A: u32 = 'A';
const LETTER_Z: u32 = 'Z';

#[cfg(test)]
mod tests {
    use super::{Letter, LetterTrait};
    use super::errors;

    #[test]
    fn test_valid_letters() {
        let letter = LetterTrait::new(0, 'A');
        assert_eq!(letter.value, 'A');
        let letter = LetterTrait::new(0, 'B');
        assert_eq!(letter.value, 'B');

        let letter = LetterTrait::new(0, 'Y');
        assert_eq!(letter.value, 'Y');
        let letter = LetterTrait::new(0, 'Z');
        assert_eq!(letter.value, 'Z');
    }

    #[test]
    #[should_panic(expected: 'Letter: not valid')]
    fn test_invalid_letter_lowercase() {
        let _letter = LetterTrait::new(0, 'a');
    }

    #[test]
    #[should_panic(expected: 'Letter: not valid')]
    fn test_invalid_letter_number() {
        let _letter = LetterTrait::new(0, '1');
    }

    #[test]
    #[should_panic(expected: 'Letter: not valid')]
    fn test_invalid_letter_shortstring() {
        let _letter = LetterTrait::new(0, 'nope');
    }
}
