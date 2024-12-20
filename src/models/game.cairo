use starknet::ContractAddress;
use super::wordle::Wordle;
use crosswordle::helpers::validity::assert_five_letter_word;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Game {
    #[key]
    player_id: ContractAddress,
    current_wordle_id: felt252,
    // letters
    l1: u8,
    l2: u8,
    l3: u8,
    l4: u8,
    l5: u8,
    // statuses
    s1: GameStatus,
    s2: GameStatus,
    s3: GameStatus,
    s4: GameStatus,
    s5: GameStatus,
    solved: bool,
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq, Debug)]
enum GameStatus {
    White,
    Yellow,
    Green,
}

const START_ID: felt252 = 9999999;

#[generate_trait]
impl GameImpl of GameTrait {
    fn new(player_id: ContractAddress) -> Game {
        Game {
            player_id,
            current_wordle_id: START_ID,
            l1: 0,
            l2: 0,
            l3: 0,
            l4: 0,
            l5: 0,
            s1: GameStatus::White,
            s2: GameStatus::White,
            s3: GameStatus::White,
            s4: GameStatus::White,
            s5: GameStatus::White,
            solved: false,
        }
    }

    fn set_guess(ref self: Game, word_byte_array: @ByteArray) -> Game {
        assert_five_letter_word(word_byte_array);

        self.l1 = word_byte_array[0];
        self.l2 = word_byte_array[1];
        self.l3 = word_byte_array[2];
        self.l4 = word_byte_array[3];
        self.l5 = word_byte_array[4];

        self
    }

    fn set_solved(ref self: Game) -> Game {
        self.solved = true;
        self
    }

    fn compare_with_wordle(ref self: Game, wordle: Wordle) -> Game {
        let solution = array![wordle.l1, wordle.l2, wordle.l3, wordle.l4, wordle.l5];
        let guess = array![self.l1, self.l2, self.l3, self.l4, self.l5];

        // First pass: Mark exact matches (green)
        let mut status: Array<GameStatus> = array![];
        let mut used_solution: Array<bool> = array![];

        let mut i = 0;
        while i < 5 {
            if solution[i] == guess[i] {
                status.append(GameStatus::Green);
                used_solution.append(true);
            } else {
                status.append(GameStatus::White);
                used_solution.append(false);
            }
            i += 1;
        };

        // Second pass: Mark partial matches (yellow)
        i = 0;
        while i < 5 {
            if status[i].clone() == GameStatus::White {
                let mut j = 0;
                while j < 5 {
                    if !used_solution[j].clone() && guess[i] == solution[j] {
                        let mut new_status: Array<GameStatus> = array![];
                        let mut new_used_solution: Array<bool> = array![];
                        let mut k = 0;
                        while k < 5 {
                            if k == i {
                                new_status.append(GameStatus::Yellow);
                            } else {
                                new_status.append(status[k].clone());
                            }

                            if k == j {
                                new_used_solution.append(true);
                            } else {
                                new_used_solution.append(used_solution[k].clone());
                            }

                            k += 1;
                        };
                        status = new_status;
                        used_solution = new_used_solution;
                        break;
                    }
                    j += 1;
                }
            }
            i += 1;
        };

        Game {
            solved: solution == guess,
            s1: status[0].clone(),
            s2: status[1].clone(),
            s3: status[2].clone(),
            s4: status[3].clone(),
            s5: status[4].clone(),
            ..self
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{Game, GameImpl, GameStatus};
    use super::super::wordle::{Wordle, WordleImpl};
    use starknet::contract_address::ContractAddressZero;

    const ALL_WHITE: (GameStatus, GameStatus, GameStatus, GameStatus, GameStatus) =
        (
            GameStatus::White,
            GameStatus::White,
            GameStatus::White,
            GameStatus::White,
            GameStatus::White
        );

    const ALL_GREEN: (GameStatus, GameStatus, GameStatus, GameStatus, GameStatus) =
        (
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green
        );

    const ALL_YELLOW: (GameStatus, GameStatus, GameStatus, GameStatus, GameStatus) =
        (
            GameStatus::Yellow,
            GameStatus::Yellow,
            GameStatus::Yellow,
            GameStatus::Yellow,
            GameStatus::Yellow
        );

    #[test]
    fn test_compare_solved() {
        let mut game = GameImpl::new(ContractAddressZero::zero());
        game.set_guess(@"APPLE");

        let wordle = WordleImpl::new(0, @"APPLE");
        let game = game.compare_with_wordle(wordle);

        assert(game.solved, 'Game should be solved');
    }

    #[test]
    fn test_not_solved() {
        let mut game = GameImpl::new(ContractAddressZero::zero());
        game.set_guess(@"NINJA");

        let wordle = WordleImpl::new(0, @"APPLE");
        let game = game.compare_with_wordle(wordle);

        assert(!game.solved, 'Game should not be solved');
    }

    #[test]
    fn test_compare_status_fullmatch() {
        let solution = WordleImpl::new(0, @"APPLE");
        let mut guess = GameImpl::new(ContractAddressZero::zero());

        guess.set_guess(@"APPLE");
        let game_status = (guess.s1, guess.s2, guess.s3, guess.s4, guess.s5);
        assert(game_status == ALL_WHITE, 'Game status should be all white');

        let compared_guess = guess.compare_with_wordle(solution);
        let game_status = (
            compared_guess.s1,
            compared_guess.s2,
            compared_guess.s3,
            compared_guess.s4,
            compared_guess.s5
        );
        assert(game_status == ALL_GREEN, 'Game status should be all green');
    }

    #[test]
    fn test_compare_status_single_4G1W() {
        let solution = WordleImpl::new(0, @"APPLE");
        let mut guess = GameImpl::new(ContractAddressZero::zero());

        guess.set_guess(@"APPLY");
        let compared_guess = guess.compare_with_wordle(solution);
        let game_status = (
            compared_guess.s1,
            compared_guess.s2,
            compared_guess.s3,
            compared_guess.s4,
            compared_guess.s5
        );
        println!("compared_guess: {:?}", game_status);

        let correct_status = (
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::White
        );
        println!("correct_status: {:?}", correct_status);
        assert(game_status == correct_status, 'Status should be GGGGE');
    }

    #[test]
    fn test_compare_status_single_3G2Y() {
        let solution = WordleImpl::new(0, @"APPLE");
        let mut guess = GameImpl::new(ContractAddressZero::zero());

        guess.set_guess(@"APPEL");
        let compared_guess = guess.compare_with_wordle(solution);
        let game_status = (
            compared_guess.s1,
            compared_guess.s2,
            compared_guess.s3,
            compared_guess.s4,
            compared_guess.s5
        );
        println!("compared_guess: {:?}", game_status);

        let correct_status = (
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Green,
            GameStatus::Yellow,
            GameStatus::Yellow
        );
        println!("correct_status: {:?}", correct_status);
        assert(game_status == correct_status, 'Status should be GGGYY');
    }

    #[test]
    fn test_compare_status_single_1G2Y2W() {
        let solution = WordleImpl::new(0, @"EERIE");
        let mut guess = GameImpl::new(ContractAddressZero::zero());

        guess.set_guess(@"ELDER");
        let compared_guess = guess.compare_with_wordle(solution);
        let game_status = (
            compared_guess.s1,
            compared_guess.s2,
            compared_guess.s3,
            compared_guess.s4,
            compared_guess.s5
        );
        println!("compared_guess: {:?}", game_status);

        let correct_status = (
            GameStatus::Green,
            GameStatus::White,
            GameStatus::White,
            GameStatus::Yellow,
            GameStatus::Yellow
        );
        println!("correct_status: {:?}", correct_status);
        assert(game_status == correct_status, 'Status should be GYYWW');
    }
}
