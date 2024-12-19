#[dojo::contract]
mod Crosswordle {
    use dojo::world::WorldStorage;
    use crosswordle::components::basewordles::BaseWordlesComponent;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        base_wordles: BaseWordlesComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        BaseWordlesEvent: BaseWordlesComponent::Event,
    }

    component!(path: BaseWordlesComponent, storage: base_wordles, event: BaseWordlesEvent);
    impl BaseWordlesInternalImpl = BaseWordlesComponent::InternalImpl<ContractState>;

    fn dojo_init(self: @ContractState) {
        self.base_wordles.add_base_wordles(self.world_storage());
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        #[inline]
        fn world_storage(self: @ContractState) -> WorldStorage {
            self.world(@"crosswordle")
        }
    }
}
