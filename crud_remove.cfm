<cfscript>
	boolean function removeCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.removeSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!COMPARABLE"
	,	string lLikeFields= ""
	,	boolean bSearchFields= true
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if( !qMetadata.recordCount ) {
			return false;
		}
		structAppend( arguments, this.stDefaults, false );
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lFilterFields= this.filterColumnList( qMetadata, arguments.lFilterFields );
		arguments.lLikeFields= this.filterColumnList( qMetadata, arguments.lLikeFields );
		arguments.lArgFields= arguments.lFilterFields;
		if( !listLen( arguments.lFilterFields ) ) {
			request.log( "!!Error: No fields to filter by. [RemoveCrud][#sTableName#]" );
			// throw( message="No fields to filter by.", type="Custom.CFC.CrudGen.RemoveCrud.NoFilterFields" );
			return false;
		}
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// if ( listLen( arguments.lFilterFields ) ) {
		// 	this.appendCommentLine( "Remove a single record from #arguments.sTableName#" );
		// 	this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" );
		// } else {
		// 	this.appendCommentLine( "Remove ALL records from #arguments.sTableName#" );
		// }
		// this.appendDivide();
		// this.appendBlank();
		//  Here is the meat and bones of it all 
		this.append( "DELETE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" );
		this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	lLikeFields= arguments.lLikeFields
		,	bSearchFields= arguments.bSearchFields
		);
		this.append( ";", false );
		this.appendBlank();
		this.append( "SELECT#this.sTab##this.sTab#@@ROWCOUNT AS row_count;" );
		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= ( arguments.bSearchFields ? arguments.lFilterFields : "" );
		// Store Param definition 
		this.addDefinition( "remove", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}
</cfscript>