//! Store struct and component management methods.

use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

use crosswordle::models::letter::Letter;

#[derive(Copy, Drop)]
struct Store {
    world: WorldStorage,
}

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline]
    fn new(world: WorldStorage) -> Store {
        Store { world: world }
    }

    #[inline]
    fn read_letter(self: Store, id: felt252) -> Letter {
        self.world.read_model(id)
    }

    #[inline]
    fn write_letter(ref self: Store, letter: Letter) {
        self.world.write_model(@letter);
    }
}
