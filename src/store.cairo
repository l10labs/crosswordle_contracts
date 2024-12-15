//! Store struct and component management methods.

use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

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
}
