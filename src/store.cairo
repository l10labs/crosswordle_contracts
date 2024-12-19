//! Store struct and component management methods.

use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

use crosswordle::models::wordle::Wordle;

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
    fn read_word(self: Store, id: u64) -> Wordle {
        self.world.read_model(id)
    }

    #[inline]
    fn write_word(ref self: Store, word: Wordle) {
        self.world.write_model(@word);
    }
}
