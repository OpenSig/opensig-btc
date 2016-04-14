# OpenSig CLI (opensig)

[![NPM](https://img.shields.io/npm/v/bitcoinjs-lib.svg)](https://www.npmjs.org/package/bitcoinjs-lib)


OpenSig Command Line Interface.  A javascript implementation of the OpenSig standard providing command line functions to digitally sign and verify files, recording signatures on the bitcoin blockchain. 

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
    create [options] [wallet]    creates a new private key and outputs its details or creates a new wallet
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
Creates a new private key and outputs its details, or creates a new wallet.
```
  Usage: 1. create [-s <label>] [-w path/to/wallet]
         2. create -k <key> -s <label> [-w path/to/wallet]
         3. create wallet [-w path/to/wallet]

  1. creates a new private key and outputs its details, optionally saving it to the wallet with the 
     given label.
  2. imports the given private key or WIF into the wallet with the given label.
  3. creates a new wallet.  If -w is not given then the default wallet is created (~/.opensig/wallet)

  Options:

    -h, --help         output usage information
    -k --key <key>     imports the given private key or WIF to the wallet.  Requires -s.
    -s --save <label>  saves the WIF and label to the wallet
```

### Sign
Creates a signature transaction and optionally publishes it on the blockchain.
```
  Usage: opensig sign [options] <file> [key]

  Signs the given file using the given key and outputs the transaction

  Options:

    -h, --help         output usage information
    -p --publish       publishes the signature on the blockchain
    --amount <amount>  spend the given amount in the transaction
    --fee <fee>        include the given miner's fee in the transaction
```
`file`  File to sign.  _(string containing a file path or a file's hex64 private key or WIF._.

`key`   Key to sign with.  _(string containing a wallet key label, hex64 private key, a WIF or a file.  If not present the default (first) key in the wallet is used.)_ 

`publish`   If present the transaction will be published on the blockchain.  Defaults to false - output the transaction to the command line only.  _(boolean)_

`amount`   Optional amount to send in the transaction.  Defaults to the minimum 5430 satoshis. _(positive integer)_

`fee`   Optional amount to include as the miner's fee.  Defaults to 10000 satoshis. _(positive integer)_

### Verify
Returns a list of signatures for the given file.

```
  Usage: opensig verify [options] <file>

  queries the blockchain and outputs the list of signatures for the given file

  Options:

    -h, --help  output usage information
```
`file`  File to verify.  _(string containing a file path or a file's public key, hex64 private key or WIF)_.

### Info
Outputs information about the given WIF, private key, wallet label or wallet.
```
  Usage: 1. opensig info [options]
         2. opensig info [options] <item>

  1. outputs information for all keys in the wallet.
  2. outputs information about the given label, WIF, private key or file.

  Options:

    -h, --help  output usage information
    --full  outputs full information.  Equivalent to --format "<full>"
```
`item`  The item to display information about.  With no arguments info outputs all keys in the wallet.

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
Returns a receipt containing a transaction to send the given amount from the `from` key to the `to` address, and, optionally, to publish the transaction on the blockchain.
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

`amount`   Amount to spend in the transaction or "all" to empty the address.  Defaults to 5430 satoshis. _(positive integer)_

`fee`   Amount to include as the miner's fee in addition to the amount.  Defaults to 10000 satoshis. _(positive integer)_

`publish`   If present the transaction will be published on the blockchain _(boolean)_

### Balance
Returns the blockchain balance for the given public address (the sum of unspent transaction outputs)
```
  Usage: opensig balance [options] [item]

  displays the balance for the given label, public key, WIF, private key or file

  Options:

    -h, --help  output usage information
```
`key`   Public key.  _(string containing a label, public key, hex64 private key, WIF or file)_ 


## Examples

Create a new wallet in the default location (~/.opensig/wallet)...
```
> opensig create wallet
```

Create a new key and save it to the wallet...
```
> opensig create -s Me
```

Get your public OpenSig address for sharing with others...
```
> opensig info --opensig
OPENSIG-1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R-btc
```

Top up your new key from another account...
```
> opensig send 100000  --to Me  --from "MyWellFundedWIF00FpYdbmJ4dbgJmr5Y1h5eX9LmsPWKBZBqkUg"  --publish
Receipt {
  from: 
   { address: '1M9jofAErijG4eiPUy19Qxot1KkPRRzyet',
     label: undefined },
  to: 
   { address: '1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R',
     label: 'Me' },
  input: 2100000000000000,
  payment: 100000,
  fee: 10000,
  change: 209999999890000,
  response: 'Transaction Submitted',
  txnID: '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
  txnHex: '04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73' }
```

Check the blockchain balance of your new key...
```
> opensig balance
100000
```

Get information about your new key in various formats...
```
> opensig info
1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R	L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL	Me

> opensig info Me
1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R	L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL	Me

> opensig info --format "<full>"

label                   : Me
private key             : a8556b1ca569679a17274299e02b4558eca4ac4f9252e7fb9221d4b99244a2b4
wif compressed          : L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL
wif uncompressed        : 5K6RSRHb73oPctb7MGWD1E5bCLzjY9EcW9kVxnkAskD9gXgzo8P
public key compressed   : 1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R
public key uncompressed : 1KxRFn875MpKYKEUEFDdZXTVxSpcjqhsNf

> opensig info --format "<pub>"
1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R

> opensig info -a
1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R

> opensig info --full

label                   : Me
private key             : a8556b1ca569679a17274299e02b4558eca4ac4f9252e7fb9221d4b99244a2b4
wif compressed          : L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL
wif uncompressed        : 5K6RSRHb73oPctb7MGWD1E5bCLzjY9EcW9kVxnkAskD9gXgzo8P
public key compressed   : 1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R
public key uncompressed : 1KxRFn875MpKYKEUEFDdZXTVxSpcjqhsNf

> opensig info --format "public key: <pub>, wif: <wif>, private key: <priv>"
public key: 1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R, wif: L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL, private key: a8556b1ca569679a17274299e02b4558eca4ac4f9252e7fb9221d4b99244a2b4

> opensig info --format "compressed keys: <pubc> <wifc>"
compressed keys: 1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R L2rvsCCDXhMkqQhZ2TRuyzjFw5FpkTM5hfczqEuYayidK2uKUnXL

> opensig info --format "uncompressed keys: <pubu> <wifu>"
uncompressed keys: 1KxRFn875MpKYKEUEFDdZXTVxSpcjqhsNf 5K6RSRHb73oPctb7MGWD1E5bCLzjY9EcW9kVxnkAskD9gXgzo8P
```

Sign a document...
```
> opensig sign my_file.doc --publish
Receipt {
  from: 
   { address: '1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R',
     label: Me },
  to: 
   { address: '16uozUn4X1yppn1nS1iQXT5u6BsqheGpUq',
     label: 'my_file.doc' },
  input: 100000,
  payment: 5430,
  fee: 10000,
  change: 84570,
  response: 'Transaction Submitted',
  txnID: '0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098',
  txnHex: '010000000109882232243a0ff09bf0fe98f3be6130935642d11508c38d22724a81a24cd813010000006a47304402200c1a88c408a29c6a192bea5fa5881113d7736b373d211809b411856fecde5fb102204f86a8e5ef8864633410d19a1a76dab72bd105275a3d06bcb222236bd88a8d96012103ef12ef92ab520c62061e07186faac5ef43e835a3ef63ddd1437d15e9fcb0dab30000000002204e0000000000001976a9141d8abe268642dda7228be625e425749f0fc5467988acf1a40000000000001976a914dd09932106e2fd0f296b726da9cb5cf142648e9588ac00000000' }
```

Verify the document...
```
> opensig verify my_file.doc
Thu, 14 Apr 2016 00:43:39 GMT	1McwqRhXr6ns7X6d3TxP3MQhVbndKg5W6R	Me
```

Get information about a file's blockchain key, check its balance and send all its funds to your address...
```
> opensig info my\_file.doc --full

label                   : my_file.doc
private key             : 773a388fbbecea7f05053b0c55dd6b5cb76e7a330e75abda01fdcf6227b6060b
wif compressed          : L1DUQpv8LHWsNiDaDzvMVugqd73Kgit3YNPVw5dEvNpXUcnAmRTT
wif uncompressed        : 5Jio5wovmhSoJcAeS9bHsxSLdGsNTDfJLo5eNKGTiYgKEbMP4f3
public key compressed   : 16uozUn4X1yppn1nS1iQXT5u6BsqheGpUq
public key uncompressed : 15DVgHc5YXLsxQMU1qrcFbhoyKdqymUvgx

> opensig balance my\_file.doc
5430

> opensig send all --from my\_file.doc --to me --publish
insufficient funds
```

### Run the tests

    $ npm test


## Copyright

OpenSig (c) 2016 D N Potter

Released under the [MIT license](LICENSE)
