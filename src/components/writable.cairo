#[starknet::component]
mod WritableComponent {
    use starknet::info::get_caller_address;
    use dojo::world::WorldStorage;

    use crosswordle::store::{Store, StoreTrait};
    use crosswordle::models::letter::{Letter, LetterTrait};

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn view_letter(self: @ComponentState<TContractState>, world: WorldStorage, key: felt252) {
            let mut store: Store = StoreTrait::new(world);
            store.read_letter(key);
        }

        fn set_letter(self: @ComponentState<TContractState>, world: WorldStorage, value: felt252) {
            let mut store: Store = StoreTrait::new(world);
            store.write_letter(LetterTrait::new(0, value));
        }
    }
}
