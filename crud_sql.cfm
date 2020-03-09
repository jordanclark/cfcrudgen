<cfscript>
	boolean function sql(
		required string sCrudName
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	required string sSql
	,	string lFilterFields= ""
	,	string lArgFields= ""
	) {
		structAppend( arguments, this.stDefaults, false );
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// this.appendCommentLine( "Execute arbitrary SQL code" );
		// this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" );
		// this.appendDivide();
		// this.appendBlank();
		// Here is the meat and bones of it all 
		this.append( attributes.sSql );
		this.appendBlank();
		// Store Param definition 
		this.addDefinition( "sql", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		if( structKeyExists( arguments, "sQueryTagFileName" ) ) {
			return this.writeDefinition( arguments.sCrudName, arguments.sQueryTagFileName, "CFC" );
		} else if( structKeyExists( arguments, "sBaseCfmDir" ) ) {
			return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCrudName#/#arguments.sFileName#", "CFC" );
		}
		return true;
	}
</cfscript>