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

/*
sui client call --function mintOnce --module stz --package 0x155996cf4cae574b497136281ab26b6b58d620c42f8dcc181c9a774f8296eceb --args 0xf039cfdb54569113f7b8c158fd6f0ca9dc7a0a8b93438a57f391a819c445960e \"100000000000\" 0xa4595b8f5aba58fdf846515125aa882ea256202c1c6b5bf0bddde5f1970db1fc --gas-budget 30000000

- ID: 0x296ab5da20857d1078b5f32119c4b3c8df755ff9279a0cf9020e25cbe15fa182 , Owner: Account Address ( 0xa6dafceb14cd8197600c1ba6fbfe2eca0dadb2f7ba4e1e568b53de6e3a71a578 )
- ID: 0x30fd2a56d66565a1674232c80b1316278e1dc897a4f82e8f4ee3a0319626802d , Owner: Immutable
- ID: 0xd067ce780e4c9e3e3febacfcc0c87851c1d2c5e5f75c6dd9c196e7657d641a75 , Owner: Account Address ( 0xa6dafceb14cd8197600c1ba6fbfe2eca0dadb2f7ba4e1e568b53de6e3a71a578 )
- ID: 0xe5d7df1b9523dfeaa01097d7725cee7faf43cc2c3830ff3540228aba8eff1a21

*/