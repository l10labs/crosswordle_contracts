use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
struct Progress {
    #[key]
    player_id: ContractAddress,
    level: u64,
    score: u64,
    possible_score: u64,
}

const MAX_SCORE: u64 = 100;
const MAX_DECREMENT: u64 = 10;

#[generate_trait]
impl ProgressImpl of ProgressTrait {
    fn new(player_id: ContractAddress) -> Progress {
        Progress { player_id, level: 1, score: 0, possible_score: MAX_SCORE }
    }

    fn update_level(self: Progress) -> Progress {
        Progress { level: self.level + 1, ..self }
    }

    fn update_score_on_correct_guess(self: Progress) -> Progress {
        Progress { score: self.score + self.possible_score, ..self }
    }

    fn lower_possible_score_on_incorrect_guess(self: Progress) -> Progress {
        if self.possible_score > 0 {
            Progress { possible_score: self.possible_score - MAX_DECREMENT, ..self }
        } else {
            self
        }
    }

    fn reset_possible_score(self: Progress) -> Progress {
        Progress { possible_score: MAX_SCORE, ..self }
    }
}
