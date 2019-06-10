component {
	property name="dsn" type="string" required="true";
	property name="debug" type="boolean" required="true" default="false";
	property name="dbTimeOut" type="numeric" required="true" default="10";
	property name="separator" type="string" required="true" default="/";
	this.lReservedNames = "_getMethodList,_loadFunctions,_renameFunctions";

	function init(required string dsn, boolean debug="false", numeric dbTimeOut="10", string separator="/") {
		this.dsn = arguments.dsn;
		this.debug = arguments.debug;
		this.dbTimeOut = arguments.dbTimeOut;
		this.separator = arguments.separator;
		return this;
	}

	string function _getMethodList(string delim=",") {
		var sKey = "";
		var lMethods = "";

		for( sKey IN this )
		{
			if( NOT listFindNoCase( this.lReservedNames, sKey ) AND isCustomFunction( this[ sKey ] ) )
			{
				lMethods = listAppend( lMethods, sKey, arguments.delim );
			}
		}
		return lCase( lMethods );
	}

	function _loadFunctions(required string names, required string prefix, string dir="#arguments.prefix#") {
		var f = "";
		// automatically include the templates 
		for ( f in arguments.names ) {
			include "#arguments.dir##this.separator##arguments.prefix##f#.cfm";
		}
		return;
	}

	function _aliasFunctions(required string sRemovePrefix) {
		var f = "";
		for ( f in variables ) {
			if ( left( f, len( sRemovePrefix ) ) == sRemovePrefix ) {
				// remove regex from function names 
				this[ replace( replace( lCase( f ), lCase( arguments.sRemovePrefix ), "", "all" ), "_", "", "all" ) ] = variables[ f ];
			}
		}
		return;
	}

}
