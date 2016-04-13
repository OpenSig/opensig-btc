/*
 * Class: opensig/Wallet
 *
 * Represents an OpenSig wallet.
 *
 * Example usage:
 *   const Wallet = require('opensig/wallet')
 *   var wallet = new Wallet( "~/.wallet" )  // create new wallet with the given file path
 *
 */

const Path = require('path');
const FS = require('fs');
const KeyPair = require('opensig-lib').KeyPair;
const Err = require('opensig-lib').Error;

function WalletError(msg, details){ return new Err.OpenSigError(1000, msg, details); }


Wallet = function( path, defaultToUncompressedKeys, forceCreate ){

 	this.path = path;
  	this.keys = [];
 	this.warnings = [];
 	this.defaultToUncompressedKeys = defaultToUncompressedKeys;
 	
 	/*
 	 * open()
 	 *
 	 * Reads the wallet file.  Throws an exception string if there is a file access problem.
 	 */
	this.open = function(){
		this.keys = readWallet(this.path, this, defaultToUncompressedKeys);
	}
	
 	/*
 	 * create()
 	 *
 	 * Creates a new wallet to the wallet file.  Throws an exception string if there is a file access problem or the wallet already exists.
 	 */
	this.create = function(){
		if( exists(this.path) ) throw new WalletError("wallet already exists");
		mkdirp(this.path);
		this.save();
	}
	
 	/*
 	 * save()
 	 *
 	 * Saves the wallet to the wallet file.  Throws an exception string if there is a file access problem.
 	 */
	this.save = function(){
		writeWallet(this.path, this.keys);
	}
	
 	/*
 	 * addKey( KeyPair)
 	 *
 	 * Adds the given KeyPair object to the wallet.  Throws an exception string if the key is
 	 * already in the wallet or the key's label is already in use.
 	 */
 	this.addKey = function addKey( key ){ 
 		if( this.hasWIF(key.wif) ) throw new WalletError("key already present in wallet");
 		if( this.hasLabel(key.label) ) throw new WalletError("key label already in use in wallet");
 		this.keys.push(key);
 	}
 	
 	/*
 	 * hasWIF( string )
 	 *
 	 * Returns true if the given Wallet Import Format key is already in the wallet.
 	 */
 	this.hasWIF = function( wif ){
 		return this.getKeyFromWIF(wif) != undefined;
 	}
 	
 	/*
 	 * hasLabel( string )
 	 *
 	 * Returns true if the given string is already used as a key label in the wallet.
 	 * Labels are case insensitive.
 	 */
 	this.hasLabel = function( label ){
 		return this.getKeyFromLabel(label) != undefined;
 	} 	
 	
 	/*
 	 * getDefaultKey()
 	 *
 	 * Returns the default signing key from this wallet
 	 */
 	this.getDefaultKey = function(){
 		if( this.keys.length == 0 ) return undefined;
 		else return this.keys[0];
 	} 
 	
 	/*
 	 * getKeyFromWIF( string )
 	 *
 	 * Returns the KeyPair from the wallet that has the given WIF, or undefined if not 
 	 * in the wallet
 	 */
 	this.getKeyFromWIF = function( wif ){
 		for( var i=0; i<this.keys.length; i++ ){ 
 			if( this.keys[i].wif == wif ) return this.keys[i];
 		}
 		return undefined;
 	}
 	
 	/*
 	 * getKeyFromPrivateKey( string )
 	 *
 	 * Returns the KeyPair from the wallet that has the given private key, or undefined if 
 	 * not in the wallet
 	 */
 	this.getKeyFromPrivateKey = function( key ){
 		for( var i=0; i<this.keys.length; i++ ){ 
 			if( this.keys[i].privateKey == key ) return this.keys[i];
 		}
 		return undefined;
 	}
 	
 	/*
 	 * getKeyFromLabel( string )
 	 *
 	 * Returns the KeyPair from the wallet that has the given WIF, or undefined if not 
 	 * in the wallet
 	 */
 	this.getKeyFromLabel = function( label ){
 		for( var i=0; i<this.keys.length; i++ ){ 
 			if( this.keys[i].label.toUpperCase() == label.toUpperCase() ) return this.keys[i];
 		}
 		return undefined;
 	}
 	
	/*
	 * getKey( key-token )
	 *
	 * returns a KeyPair that corresponds to the given token, where the token can be:
	 *   undefined or "" (the default key is used); "default-key"; the label of a wallet key; 
	 *   a private key; or a wif.
	 */
	this.getKey = function( token ){
		var keyPair = undefined;
		if( token == undefined || token == "default-key" || token == "" ){
			keyPair = this.getDefaultKey();
		}
		else if( isWIF(token) ){ 
			keyPair = this.getKeyFromWIF(token);
		}
		else if( isPrivateKey(token) ){
			keyPair = this.getKeyFromPrivateKey(token);
		}
		else if( this.hasLabel(token) ){
			keyPair = this.getKeyFromLabel(token);
		}
		return keyPair;
	}


 	/*
 	 * toString( [format] )
 	 *
 	 * Returns a string representation of this object.  Each line of the output contains
 	 * a different key in the given format, defined below.
 	 * 
	 * format: string representation of the output format containing the following
	 *         substrings for substitution
	 *    <label>  the key's label
	 *    <pub>    the public key (blockchain address)
	 *    <priv>   the private key
	 *    <wif>    the Wallet Import Format version of the private key
	 */
	this.toString = function( format ){
		var output = "";
		for( var i=0; i<this.keys.length; i++ ){
			if( i > 0 ) output += "\n";
			output += this.keys[i].toString(format);
		}
		return output;
	}
	
 	/*
 	 * logWarning( string )
 	 *
 	 * Internal function used to log a warning to the wallet when reading the wallet file
 	 */
	this.logWarning = function( str ){
		this.warnings.push(str);
	}
	
 	/*
 	 * hasWarnings()
 	 *
 	 * Returns true if any warnings were logged while reading the wallet file.
 	 */
	this.hasWarnings = function(){
		return this.warnings.length > 0;
	}
	
 	/*
 	 * dumpWarnings()
 	 *
 	 * Returns a string containing a list of warnings logged while reading the wallet.
 	 * Warnings are separated by a newline.  If no warnings were logged then an empty 
 	 * string is returned.
 	 */
	this.dumpWarnings = function(){
		var str = "";
		for( var i=0; i<this.warnings.length; i++ ){
			if( i > 0 ) str += "\n";
			str += this.warnings[i];
		}
		return str;
	}
	
	// Open or create the wallet
	forceCreate ? this.create() : this.open();

 }

module.exports = Wallet;


/*
 * readWallet
 *
 * Internal function to read the given wallet file and return an array of KeyPair objects
 */
function readWallet( file, logger, defaultToUncompressedKeys ){
	var rawWalletData;
	try{
		rawWalletData = FS.readFileSync(file, 'utf8');
	}
	catch(err){ 
		throw new Err.FileSystemError(err); 
	}
	var lines = rawWalletData.split("\n");
	var keys = [];
	for( var i=0; i<lines.length; i++ ){
		if( lines[i] != "" ){
			var fields = lines[i].split("	");
			if( fields.length != 2 ){
				logger.logWarning("warning - ignoring corrupt wallet entry: " + lines[i]);
			}
			else{
				try{
					var entry = new KeyPair( fields[1], fields[0], defaultToUncompressedKeys );
					keys.push( entry );
				}
				catch(err){
					logger.logWarning("warning - ignoring corrupt wallet entry (" + err + "): "+ lines[i]);
				}
			}
		}
	}
	return keys;
}


/*
 * writeWallet
 *
 * Internal function to write the given array of KeyPair objects to the given path
 */
 function writeWallet( path, keys ){
 	var data = "";
 	for( var i=0; i<keys.length; i++ ){
 		var key = keys[i];
		if( i > 0 ) data += "\n";
 		data += key.wifC+"	"+key.label;
 	}
 	try{
 		FS.writeFileSync( path, data, { encoding: "utf8", mode: 0600 } );
 	}
 	catch(err){
		throw new Err.FileSystemError(err); 
 	}
 }


/*
 * mkdirp <path>
 *
 * creates the directory tree of the given path, if it does not exist.
 */
function mkdirp(path) {
	var dirname = Path.dirname(path);
	if( exists(dirname, "d") ) return true;
	else{
		mkdirp(dirname);
		FS.mkdirSync(dirname, 0700);
	}
}

/*
 * exists <path> [type]
 *
 * returns true if the path exists and is of the given type.
 */
function exists(path, type) {
	try {
		switch (type){
			case "d": return FS.statSync(path).isDirectory();
			default:  return FS.statSync(path).isFile();
		}
	}
	catch (err) {
		return false;
	}
} 

function isWIF( str ){ return str && str.match('^[5KL][1-9A-HJ-NP-Za-km-z]{50,51}$'); }
function isPrivateKey( str ){ return str && str.match('[0-9a-z]{60,64}'); }
