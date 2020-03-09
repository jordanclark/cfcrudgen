<cfscript>
	boolean function selectCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.selectSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!NOTNULL,!COMPARABLE"
	,	string lSelectFields= "*"
	,	string lLikeFields= ""
	,	string sOrderBy= ""
	,	boolean bSearchFields= true
	,	boolean bRowLimit= true
	,	string sType= "select"
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if( !qMetadata.recordCount ) {
			return false;
		}
		structAppend( arguments, this.stDefaults, false );
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lFilterFields= this.filterColumnList( qMetadata, arguments.lFilterFields );
		arguments.lSelectFields= this.filterColumnList( qMetadata, arguments.lSelectFields );
		arguments.lLikeFields= this.filterColumnList( qMetadata, arguments.lLikeFields );
		arguments.lArgFields= arguments.lFilterFields;
		if( !listLen( arguments.lSelectFields ) ) {
			request.log( "!!Error: No fields to filter by. [SelectCrud][#sTableName#]" );
			// throw( message="No fields to select.", type="Custom.CFC.CrudGen.SelectCrud.NoSelectFields" );
			return false;
		}
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// if ( listLen( arguments.lFilterFields ) ) {
		// 	this.appendCommentLine( "Select a single record from #uCase( arguments.sTableName )#" );
		// 	this.appendCommentLine( "based on fields: #uCase( replace( arguments.lFilterFields, ',', ', ', 'all' ) )#" );
		// } else {
		// 	this.appendCommentLine( "Select ALL records from #uCase( arguments.sTableName )#" );
		// }
		// this.appendDivide();
		// this.appendBlank();
		// Here is the meat and bones of it all 
		this.appendLine( "SELECT#this.sTab#" );
		if( arguments.bRowLimit ) {
			this.appendOn( "#this.sTab#<cfif arguments.rows GT 0>TOP (##arguments.rows##)</cfif>" );
		}
		// this.append( this.sTab & this.sTab );
		this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lSelectFields
		,	bAliasFields= true
		,	bNewLine= arguments.bRowLimit
		);
		this.append( "FROM#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" );
		this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	lLikeFields= arguments.lLikeFields
		,	bSearchFields= arguments.bSearchFields
		);
		if( len( arguments.sOrderBy ) ) {
			this.append( "ORDER BY#this.sTab##arguments.sOrderBy#" );
		}
		this.append( ";", false );
		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= ( arguments.bSearchFields ? arguments.lFilterFields : "" );
		// Store Param definition 
		this.addDefinition( arguments.sType, arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}	
</cfscript>