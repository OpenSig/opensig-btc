# OpenSig Library (opensig-lib)

[![NPM](https://img.shields.io/npm/v/bitcoinjs-lib.svg)](https://www.npmjs.org/package/bitcoinjs-lib)


Blockchain e-sign library.  A javascript library that implements the opensig e-sign protocol providing functions to sign and verify files, recording signatures on the bitcoin blockchain. 

## Primary Features
- **Create**: generate a new private key and optionally add it to your wallet.
- **Sign**: sign any file with your private key and record your signature on the blockchain.
- **Verify**: display a file's signatures from the blockchain.
- **Info**: obtain private key, wif and public keys from any private key, WIF or file, or from a key in your wallet.

## Secondary Features
- **Send**: create and publish a transaction to spend any amount from one address to another.
- **Balance**: retrieve the balance of your key (or any public key) from the blockchain.


## Installation

`npm install opensig -g`

## Usage

```
  Usage: opensig <command> [options] [args]   # Try opensig <command> --help


  Commands:

    info [options] [item]        outputs information about the given WIF, private key or wallet.
    create [options]             creates a new private key and outputs its details
    verify <file>                queries the blockchain and outputs the list of signees for the given file
    sign [options] <file> [key]  signs the given file using the given key and outputs the transaction
    send [options] <amount>      creates a transaction
    balance [item]               displays the balance for the given public key, WIF, label or private key

  Options:

    -h, --help             output usage information
    -V, --version          output the version number
    -a --address           limit output to compressed public blockchain address(es) only.  Overrides -f
    -f --format <format>   specify the output format (see documentation)
    -w --wallet <file>     use the specified wallet file instead of the default wallet
    -v --verbose           display verbose error information
    --test-blockchain-api  places the blockchain api interface into test mode
```

### Create
```
  Usage: opensig create [options]

  creates a new private key and outputs its details

  Options:

    -h, --help         output usage information
    -k --key <key>     imports the given private key or WIF to the wallet.  Requires -s.
    -s --save <label>  saves the WIF and label to the wallet
```

### Sign
```
  Usage: opensig sign [options] <file> [key]

  signs the given file using the given key and outputs the transaction

  Options:

    -h, --help         output usage information
    -p --publish       publishes the signature on the blockchain
    --amount <amount>  spend the given amount in the transaction
    --fee <fee>        include the given miner's fee in the transaction
```
`file`  File to sign.  _(string containing a file path or a file's hex64 private key or WIF._.

`key`   Key to sign with.  _(string containing a wallet key label, hex64 private key, a WIF or a file.  If not present the first key in the wallet is used.)_ 

`publish`   If present the transaction will be published on the blockchain.  Defaults to outputting the transaction locally.  _(boolean)_

`amount`   Optional amount to send in the transaction.  Defaults to 5430 satoshis. _(positive integer)_

`fee`   Optional amount to include as the miner's fee.  Defaults to 10000 satoshis. _(positive integer)_

### Verify
Returns a promise to resolve an array of Signature objects containing the list of signatures for the given file.

```
  Usage: opensig verify [options] <file>

  queries the blockchain and outputs the list of signees for the given file

  Options:

    -h, --help  output usage information
```
`file`  File to verify.  _(string containing a file path or a file's hex64 private key or WIF)_.

### Info
```
  Usage: opensig info [options] [item]

  outputs information about the given WIF, private key or wallet.

  Options:

    -h, --help  output usage information
    --full  outputs full information.  Equivalent to --format "<full>"
```
`item`  The item to display information about.  With no arguments info outputs the wallet.

By default info outputs the public key, private WIF and label of the item requested.  Use the -f <format> option to control the output format, where <format> is a string containing free text and any of the following fields:
`label`  the key's label
`pub`    the public key (blockchain address)
`priv`   the private key (hex64)
`wif`    the Wallet Import Format version of the private key
`pubc`   public key (compressed form)
`pubu`   public key (uncompressed form)
`wifc`   wif (compressed form)
`wifu`   wif (uncompressed form)


### Send
Returns a promise to resolve a Receipt object containing a transaction to send the given amount from the `from` key to the `to` address, and, optionally, to publish the transaction on the blockchain.
```
  Usage: opensig send [options] <amount>

  creates a transaction

  Options:

    -h, --help     output usage information
    -p --publish   publishes the signature on the blockchain
    --to <to>      send to this label, public address, private key, wif or file
    --from <from>  send from this label, private key, wif or file
    --fee <fee>    use the given miner's fee
```
`from`  Wallet key label, private key or wif of the address to spend from.  _(string containing a label, hex64 private key or WIF.  Also accepts a file)_.

`to`   Wallet key label, public key, private key or wif of the address to send to.  _(string containing a label, public key, hex64 private key or WIF.  Also accepts a file)_ 

`amount`   Amount to spend in the transaction.  Defaults to 5430 satoshis. _(positive integer)_

`fee`   Amount to include as the miner's fee in addition to the amount.  Defaults to 10000 satoshis. _(positive integer)_

`publish`   If present the transaction will be published on the blockchain _(boolean)_

### Balance
Returns a promise to resolve the sum of unspent transaction outputs retrieved from the blockchain for the given public key.
```
  Usage: opensig balance [options] [item]

  displays the balance for the given public key, WIF, label or private key

  Options:

    -h, --help  output usage information
```
`key`   Public key.  _(string containing a label, public key, hex64 private key, WIF or file)_ 


## Examples

Create a new wallet in the default location (~/.opensig/wallet)...
```
opensig create wallet
```

Create a new key and save it to the wallet...
```
opensig create -s Me
```

Top up your new key from another account...
```
opensig send 100000  --to Me  --from "MyWellFundedWIF00FpYdbmJ4dbgJmr5Y1h5eX9LmsPWKBZBqkUg"  --publish
```

Check the blockchain balance of your new key...
```
opensig balance
```

Get information about your new key in various formats...
```
opensig info
opensig info Me
opensig info --format "<full>"
opensig info --format "<pub>"
opensig info -a
opensig info --full
opensig info --format "public key: <pub>, wif: <wif>, private key: <priv>"
opensig info --format "compressed keys: <pubc> <wifc>"
opensig info --format "uncompressed keys: <pubu> <wifu>"
```

Sign a document...
```
opensig sign my_file.doc
```

Verify the document...
```
opensig verify my_file.doc
```

Get information about a file's blockchain key, check its balance and send all its funds to your address...
```
opensig info my\_file.doc --full
opensig balance my\_file.doc
opensig send all --from my\_file.doc --to me --publish
```


### Run the tests

    $ npm test


## Copyright

OpenSig (c) 2016 D N Potter

Released under the [MIT license](LICENSE)
