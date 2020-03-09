<cfscript>
	boolean function updateCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.updateSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!PK"
	,	string lLikeFields= ""
	,	string lUpdateFields= "*"
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if( !qMetadata.recordCount ) {
			return false;
		}
		structAppend( arguments, this.stDefaults, false );
		request.log( "!!UPDATE FILTER FIELD: [#arguments.lFilterFields#][#arguments.lUpdateFields#]" );
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lFilterFields= this.filterColumnList( qMetadata, arguments.lFilterFields );
		arguments.lLikeFields= this.filterColumnList( qMetadata, arguments.lLikeFields );
		arguments.lUpdateFields= this.filterColumnList( qMetadata, arguments.lUpdateFields );
		arguments.lUpdateFields= this.filterColumnList( qMetadata, udf.listRemoveListNoCase( arguments.lUpdateFields, arguments.lFilterFields ) );
		arguments.lArgFields= this.filterColumnList( qMetadata, listAppend( arguments.lFilterFields, arguments.lUpdateFields ) );
		request.log( "!!UPDATE FILTER FIELD: [#arguments.lFilterFields#][#arguments.lUpdateFields#]" );
		if( !listLen( arguments.lUpdateFields ) ) {
			request.log( "!!Error: No fields to update. [UpdateCrud][#sTableName#]" );
			// throw( message="No fields to update.", type="Custom.CFC.CrudGen.UpdateCrud.NoUpdateFields" );
			return false;
		}
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// if ( listLen( arguments.lFilterFields ) ) {
		// 	this.appendCommentLine( "Update a single record from #arguments.sTableName#" );
		// 	this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" );
		// } else {
		// 	this.appendCommentLine( "Update ALL records from #arguments.sTableName#" );
		// }
		// this.appendDivide();
		// this.appendBlank();
		// Here is the meat and bones of it all 
		this.append( "DECLARE#this.sTab##this.sTab#@rows INT;" );
		this.appendBlank();
		this.append( "UPDATE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" );
		this.append( "SET#this.sTab##this.sTab#" );
		this.appendUpdateFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lUpdateFields
		,	bSelectFields= true
		,	bNewLine= false
		);
		this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	lLikeFields= arguments.lLikeFields
		,	bSearchFields= false
		);
		this.append( ";", false );
		this.appendBlank();
		this.append( "SELECT#this.sTab##this.sTab#@@ROWCOUNT AS row_count;" );
		// this.appendErrorCheck();
		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= arguments.lUpdateFields;
		// Store Param definition 
		this.addDefinition( "update", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}
</cfscript>