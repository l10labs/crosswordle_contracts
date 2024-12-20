//! Store struct and component management methods.

use dojo::world::WorldStorage;
use dojo::model::ModelStorage;
use starknet::ContractAddress;

use crosswordle::models::wordle::Wordle;
use crosswordle::models::game::Game;
use crosswordle::models::progress::Progress;

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
    fn read_wordle(self: Store, id: felt252) -> Wordle {
        self.world.read_model(id)
    }

    #[inline]
    fn write_wordle(ref self: Store, wordle: Wordle) {
        self.world.write_model(@wordle);
    }

    #[inline]
    fn read_game(self: Store, id: ContractAddress) -> Game {
        self.world.read_model(id)
    }

    #[inline]
    fn write_game(ref self: Store, game: Game) {
        self.world.write_model(@game);
    }

    #[inline]
    fn read_progress(self: Store, id: ContractAddress) -> Progress {
        self.world.read_model(id)
    }

    #[inline]
    fn write_progress(ref self: Store, progress: Progress) {
        self.world.write_model(@progress);
    }
}

