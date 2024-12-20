#[starknet::component]
mod GameStartComponent {
    use dojo::world::WorldStorage;
    use starknet::get_caller_address;

    use crosswordle::store::{Store, StoreTrait};
    use crosswordle::models::game::{Game, GameTrait};
    use crosswordle::models::wordle::{Wordle, WordleTrait};
    use crosswordle::models::progress::{Progress, ProgressTrait};

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn add_game(self: @ComponentState<TContractState>, world: WorldStorage) {
            let mut store: Store = StoreTrait::new(world);

            let player_id = get_caller_address();

            let game: Game = GameTrait::new(player_id);
            store.write_game(game);

            let progress: Progress = ProgressTrait::new(player_id);
            store.write_progress(progress);
        }

        fn start_game(self: @ComponentState<TContractState>, world: WorldStorage) {
            let mut store: Store = StoreTrait::new(world);

            let mut game: Game = store.read_game(get_caller_address());
            game.assert_new();

            let get_random_wordle_id = 0;
            game = game.set_wordle_id(get_random_wordle_id);

            store.write_game(game);
        }

        fn guess_word(
            self: @ComponentState<TContractState>, world: WorldStorage, word_byte_array: @ByteArray
        ) {
            let mut store: Store = StoreTrait::new(world);

            let mut game: Game = store.read_game(get_caller_address());
            game.assert_in_progress();

            game = game.set_guess(word_byte_array);
            store.write_game(game);
        }

        fn compare_guess_to_solution(self: @ComponentState<TContractState>, world: WorldStorage) {
            let mut store: Store = StoreTrait::new(world);

            let mut game: Game = store.read_game(get_caller_address());
            game.assert_in_progress();

            let wordle_id = game.current_wordle_id;
            let wordle: Wordle = store.read_wordle(wordle_id);

            game = game.compare_with_wordle(wordle);
            // game.set_solved();

            store.write_game(game);
        }

        fn check_for_next_level(self: @ComponentState<TContractState>, world: WorldStorage) {
            let mut store: Store = StoreTrait::new(world);

            let mut game: Game = store.read_game(get_caller_address());
            let mut progress: Progress = store.read_progress(get_caller_address());

            if game.is_solved() {
                let mut next_game = GameTrait::new(get_caller_address());
                let next_wordle_id = game.current_wordle_id + 1;
                next_game = next_game.set_wordle_id(next_wordle_id);
                game = next_game;

                progress = progress.update_level();
                progress = progress.update_score_on_correct_guess();
                progress = progress.reset_possible_score();
            } else {
                progress = progress.lower_possible_score_on_incorrect_guess();
            }

            store.write_game(game);
            store.write_progress(progress);
        }
    }
}
