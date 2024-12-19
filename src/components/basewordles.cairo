#[starknet::component]
mod BaseWordlesComponent {
    use dojo::world::WorldStorage;

    use crosswordle::store::{Store, StoreTrait};
    use crosswordle::models::wordle::{Wordle, WordleTrait};

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    const NUM_OF_WORDS: usize = 10;
    fn wordle_list() -> Array<ByteArray> {
        let wordle_list = array![
            "STARK", "SWORD", "NINJA", "OHAYO", "TORII", "CAIRO", "HELLO", "WORLD", "BLOCK", "CHAIN"
        ];
        assert(wordle_list.len() == NUM_OF_WORDS, 'Wordle list length mismatch');

        wordle_list
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn add_base_wordles(self: @ComponentState<TContractState>, world: WorldStorage) {
            let mut store: Store = StoreTrait::new(world);
            let wordle_list = wordle_list();
            let mut i: usize = 0;
            while i < NUM_OF_WORDS {
                let wordle: Wordle = WordleTrait::new(i.into(), wordle_list.at(i));
                store.write_word(wordle);
                i += 1;
            }
        }
    }
}
