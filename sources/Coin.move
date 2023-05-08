// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example coin with a trusted manager responsible for minting/burning (e.g., a stablecoin)
/// By convention, modules defining custom coin types use upper case names, in contrast to
/// ordinary modules, which use camel case.
module fungible_tokens::stz {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::url;
    use sui::tx_context::{Self, TxContext};

    /// A shared counter.
    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields. The full type of the coin defined by this module will be `COIN<STZ>`.
    struct STZ has drop {}

    /// Register the managed currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: STZ, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<STZ>(witness, 5, b"STZ", b"Suitizen", b"", option::some(url::new_unsafe_from_bytes(b"https://i.imgur.com/rJnMzhr.png")), ctx);
        let tc = &mut treasury_cap;
        coin::mint_and_transfer(tc, 100_000_000_000_000, tx_context::sender(ctx), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    /// Manager can burn coins
    public entry fun burn(treasury_cap: &mut TreasuryCap<STZ>, coin: Coin<STZ>) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(STZ {}, ctx)
    }
}
