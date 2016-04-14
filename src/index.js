/*
 * OpenSig cli main file
 *
 * use --help for usage information
 *
 */

// Modules
const Commander = require('commander');
const opensig  = require('opensig-lib');
const Wallet   = require('./wallet');
const OS       = require('os');

// Constants
const program = new Commander.Command("opensig");
const defaultWalletFile = OS.homedir() + "/.opensig/wallet";

// MAIN
 
program
	.version('1.0.0-alpha')
	.usage('<command> [options] [args]   # Try opensig <command> --help')
	.option('-a --address', 'limit output to compressed public blockchain address(es) only.  Overrides -f')
	.option('-f --format <format>', 'specify the output format (see documentation)')
	.option('-w --wallet <file>', 'use the specified wallet file instead of the default wallet')
	.option('-v --verbose', 'display verbose error information')
	.option('--test-blockchain-api', 'places the blockchain api interface into test mode' );


// INFO Command
program
	.command('info [item]')
	.description('outputs information about the given WIF, private key or wallet.')
	.option('--full', 'outputs full information.  Equivalent to --format "<full>"')
	.option('-o --opensig', 'outputs in OpenSig text format.')
	.action(function(item, options){
		try{
			// args and options
			item = item || "default-key";
			var publicAddressOnly = program.address || false;
			var fullOutput   = options.full || false;
			var opensigOutput   = options.opensig || false;
			var format = program.format || "";
			var walletFile = program.wallet || defaultWalletFile;

			// determine output format
			format = fullOutput ? "<full>" : format;
			format = publicAddressOnly ? "<pub>" : format;
			format = opensigOutput ? "OPENSIG-<pub>-btc" : format;

			// command
			var wallet = new Wallet( walletFile );
			wallet.open();
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );
			if( item == undefined || item == "" ){
				throw "Key cannot be empty";
			}
			else if( item == "wallet" ){
				end( wallet.toString(format) );
			}
			else{
				var key = wallet.getKey(item);
				if( key ) end( key.toString(format) );
				else opensig.getKey(item)
					.then( 
						function output(key){ 
							end( key.toString(format) ); 
						} )
					.catch( 
						function logError(err){
							fatalError("argument is not a valid wallet label, private key, readable file or wif");
						} );
			}
		}
		catch(err){ fatalError(err); }
	});


// CREATE Command
program
	.command('create [wallet]')
	.description('creates a new private key and outputs its details or creates a new wallet')
	.option('-k --key <key>', 'imports the given private key or WIF to the wallet.  Requires -s.')
	.option('-s --save <label>', 'saves the WIF and label to the wallet')
	.action(function(wallet, options){
		try{
			// args and options
			var privateKey = options.key;			
			var saveLabel  = options.save;	
			var publicAddressOnly = program.address || false;
			var walletFile = program.wallet || defaultWalletFile;
			var createWallet = (wallet == "wallet");

			// determine output format
			var format = program.format || "<full>";
			format = publicAddressOnly ? "<pub>" : format;

			// command
			var wallet = new Wallet( walletFile, false, createWallet );
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );

			if( ! createWallet ){
				if( privateKey ){ // import the given key
					if( saveLabel ){
						wallet.addKey( opensig.create(saveLabel, privateKey) );
						wallet.save();
					}
					else{ throw "Cannot import key without a label - use -s to specify" }
				}		
				else if( saveLabel ){ // save a new key with the given label to the wallet
					wallet.addKey( opensig.create( saveLabel ) );
					wallet.save();
				}
				else{ // just output a new key
					var key = opensig.create();
					console.log( key.toString(format) );
				}
			}
			process.exit(0);
		}
		catch(err){ fatalError(err); }
	});


// VERIFY Command
program
	.command('verify <file>')
	.description('queries the blockchain and outputs the list of signees for the given file')
	.action(function(file, options){
		try{ 
			// args and options
			var publicAddressOnly = program.address || false;

			// determine output format
			var format = program.format || "<longtime>	<pub>	<label>";
			format = publicAddressOnly ? "<pub>" : format;

			// command
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );
			opensig.verify(file).then( 
				function( response ){ outputVerification( response, format ); } 
				).catch( fatalError );
		}
		catch(err){ fatalError(err); }
	});


// SIGN Command
program
	.command('sign <file> [key]')
	.description('signs the given file using the given key and outputs the transaction')
	.option('-p --publish', 'publishes the signature on the blockchain')
	.option('--amount <amount>', 'spend the given amount in the transaction')
	.option('--fee <fee>', 'include the given miner\'s fee in the transaction')
	.action(function(file, key, options){
		try{
			// args and options
			var publish = options.publish || false;
			var walletFile = program.wallet || defaultWalletFile;

			// command
			var wallet = new Wallet( walletFile );
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );
			key = wallet.getKey(key) || key;
			opensig.sign(file, key, publish, options.amount, options.fee).then( end ).catch( fatalError );
		}
		catch(err){ fatalError(err); }
	});


// SEND Command
program
	.command('send <amount>')
	.description('creates a transaction')
	.option('-p --publish', 'publishes the signature on the blockchain')
	.option('--to <to>', 'send to this label, public address, private key, wif or file')
	.option('--from <from>', 'send from this label, private key, wif or file')
	.option('--fee <fee>', 'use the given miner\'s fee')
	.action(function(amount, options){
		try{
			// args and options
			var publish = options.publish || false;
			var walletFile = program.wallet || defaultWalletFile;
			
			// command
			var wallet = new Wallet( walletFile );
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );
			var from = wallet.getKey(options.from) || options.from;
			var to = wallet.getKey(options.to) || options.to;

			// validate parameters
			if( !options.to ) throw "  error: missing required argument --to";
			if( !from ) throw "wallet has no default key";
			
			// send
			opensig.send(from, to, amount, options.fee, publish ).then( end ).catch( fatalError );
		}
		catch(err){ fatalError(err); }
	});


// BALANCE Command
program
	.command('balance [item]')
	.description('displays the balance for the given public key, WIF, label or private key')
	.action(function(item, options){
		try{
			// args and options
			item = item || "default-key";
			var walletFile = program.wallet || defaultWalletFile;

			// command
			var wallet = new Wallet( walletFile );
			opensig.blockchainAPI.setTestMode( program.testBlockchainApi );
			item = wallet.getKey(item) || item;
			opensig.balance( item ).then( end ).catch( fatalError );
		}
		catch(err){ fatalError(err); }
	});

program.parse(process.argv);
if( program.args.length == 0 ){ program.outputHelp(); }


function outputVerification( signatures, format ){ 
	if( signatures == undefined ){ fatalError("Internal error: blockchain verification produced undefined result"); }
	for ( var sig in signatures ){ 
		console.log(signatures[sig].toString(format)) 
	}
	process.exit(0);
}


function end( msg ){
	console.log(msg);
	process.exit(0);
}

function fatalError( err ){
	if( err.name == "OpenSigError" ){
		if( program.verbose ) console.error(err.message+"\nDetails: "+err.details);
		else console.error(err.message);
	}
	else console.error(err);
	process.exit(1);
}

function getOption( program, env, options, name, defaultValue ){
	if( program[name] ) return program[name];
	if( env && env[name] ) return env[name];
	if( options && options[name] ) return options[name];
	return defaultValue;
}


