component {

	function init( required string path, required struct db, string preload= "" ) {
		this.path= arguments.path;
		this.flush();
		this.settings= {
			db= arguments.db
		};
		if ( len( arguments.preload ) ) {
			cftimer( type="debug", label="Crud Preload: #replace( arguments.preload, ',', ', ', 'all' )#" ) {
				this.loadList(
					names= arguments.preload
				,	force= false
				);
			}
		}
		return this;
	}

	function executeOut( required string crud, boolean force= false ) {
		var cfc= this.get( listFirst( arguments.crud, "." ), arguments.force );
		var out= this[ listRest( arguments.crud, "." ) ](
			argumentCollection= arguments
		);
		return out;
	}

	function execute( required string crud, boolean force= false ) {
		var cfc= this.get( listFirst( arguments.crud, "." ), arguments.force );
		out= this[ listRest( arguments.crud, "." ) ](
			argumentCollection= arguments
		);
	}

	function get( required string name, boolean force= false ) {
		if ( structKeyExists( this.lookup, arguments.name ) ) {
			return this.lookup[ arguments.name ];
		}
		arguments.lookup= arguments.name;
		if ( find( "_", arguments.name ) ) {
			arguments.name= this.camelCase( arguments.name );
		}
		this.load(
			name= arguments.name
		,	lookup= arguments.lookup
		,	force= arguments.force
		);
		return this.table[ arguments.name ];
	}

	function load( required string name, boolean force= false, string lookup= "" ) {
		var crud= 0;
		arguments.compName= ( len( this.path ) ? this.path & "." : "" )
			& reReplace( arguments.name, "([[:lower:]|0-9])([[:upper:]])", "\1_\L\2", "all" )
			& "." & arguments.name & "Crud";
		if ( arguments.force || !structKeyExists( this.table, arguments.name ) ) {
			request.log( "Loading crud #arguments.compName#" );
			crud= createObject( "component", arguments.compName );
			if ( structKeyExists( crud, "init" ) ) {
				crud.init( argumentCollection= this.settings );
			}
			this.table[ arguments.name ]= crud;
		}
		if ( len( arguments.lookup ) ) {
			this.lookup[ arguments.lookup ]= this.table[ arguments.name ];
		}
		return;
	}

	function loadList( required string names, boolean force= false ) {
		var index= "";
		for ( index in arguments.names ) {
			this.load(
				name= index
			,	lookup= index
			,	force= arguments.force
			);
		}
		return;
	}

	function flush() {
		this.table= {};
		this.lookup= {};
		return;
	}

	string function camelCase( required string sInput, string sDelim= "_" ) {
		var out= "";
		var word= "";
		var i= 1;
		var strlen= listLen( arguments.sInput, arguments.sDelim );
		if ( !len( arguments.sInput ) ) {
			return arguments.sInput;
		}

		for( i=1; i LTE strlen; i=i+1 ) {
			word= listGetAt( arguments.sInput, i, arguments.sDelim );
			out= out & uCase( left( word, 1 ) );
			if( len( word ) GT 1 ) {
				out= out & right( word, len( word ) - 1 );
			}
			if( i LT strlen ) {
				out= out;
			}
		}
		// request.log( "!!CAMEL: #arguments.sInput#= #out#" );
		// camel-case the first letter 
		out= lCase( left( out, 1 ) ) & right( out, len( out ) - 1 );
		return out;
	}

}
