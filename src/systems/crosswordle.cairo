#[starknet::interface]
trait ICrosswordleTrait<TContractState> {
    fn start_game(self: @TContractState);
    fn guess_word(self: @TContractState, word_byte_array: ByteArray);
}

#[dojo::contract]
mod Crosswordle {
    use dojo::world::WorldStorage;
    use super::ICrosswordleTrait;
    use crosswordle::components::basewordles::BaseWordlesComponent;
    use crosswordle::components::gamestart::GameStartComponent;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        base_wordles: BaseWordlesComponent::Storage,
        #[substorage(v0)]
        game_start: GameStartComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        BaseWordlesEvent: BaseWordlesComponent::Event,
        #[flat]
        GameStartEvent: GameStartComponent::Event,
    }

    component!(path: BaseWordlesComponent, storage: base_wordles, event: BaseWordlesEvent);
    impl BaseWordlesInternalImpl = BaseWordlesComponent::InternalImpl<ContractState>;

    component!(path: GameStartComponent, storage: game_start, event: GameStartEvent);
    impl GameStartInternalImpl = GameStartComponent::InternalImpl<ContractState>;

    fn dojo_init(self: @ContractState) {
        self.base_wordles.add_base_wordles(self.world_storage());
    }

    #[abi(embed_v0)]
    impl CrosswordleImpl of ICrosswordleTrait<ContractState> {
        fn start_game(self: @ContractState) {
            self.game_start.add_game(self.world_storage());
            self.game_start.start_game(self.world_storage());
        }

        fn guess_word(self: @ContractState, word_byte_array: ByteArray) {
            self.game_start.guess_word(self.world_storage(), @word_byte_array);
            self.game_start.compare_guess_to_solution(self.world_storage());
            self.game_start.check_for_next_level(self.world_storage());
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        #[inline]
        fn world_storage(self: @ContractState) -> WorldStorage {
            self.world(@"crosswordle")
        }
    }
}
