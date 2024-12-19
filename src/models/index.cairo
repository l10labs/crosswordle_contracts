#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Wordle {
    #[key]
    id: felt252,
    l1: u8,
    l2: u8,
    l3: u8,
    l4: u8,
    l5: u8,
}
