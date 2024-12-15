#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Letter {
    #[key]
    id: felt252,
    value: felt252,
}
