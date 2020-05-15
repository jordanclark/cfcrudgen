<cfscript>
	boolean function upsertCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.upsertSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!PK"
	,	string lInsertFields= "!MUTABLE"
	,	string lOptionalFields= "!NULL"
	,	string lUpdateFields= "!MUTABLE"
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if ( !qMetadata.recordCount ) {
			return false;
		}
		var sTransName= left( replaceNoCase( replace( arguments.sCrudName, "_", "", "all" ), "gsp", "tran_" ), 32 );
		structAppend( arguments, this.stDefaults, false );
		arguments.bIdentityField= ( arrayFind( qMetadata.columnData( "isIdentity" ), 1 ) ? true : false );
		arguments.sIdentityField= qMetadata.filter( function( r ) { return r.isIdentity == 1; } ).fieldName;
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lFilterFields= this.filterColumnList( qMetadata, arguments.lFilterFields );
		arguments.lInsertFields= this.filterColumnList( qMetadata, arguments.lInsertFields );
		arguments.lOptionalFields= this.filterColumnList( qMetadata, arguments.lOptionalFields );
		arguments.lRequiredFields= udf.listRemoveListNoCase( arguments.lInsertFields, arguments.lOptionalFields );
		arguments.lUpdateFields= udf.listRemoveListNoCase( this.filterColumnList( qMetadata, arguments.lUpdateFields ), arguments.lFilterFields );
		arguments.lArgFields= listRemoveDuplicates( listAppend( arguments.lFilterFields, arguments.lInsertFields ), ",", true );
		arguments.sParamsPrefix= "@" & this.getSqlSafeName( listLast( arguments.sTableName, '.' ) ) & "_";
		/* if( arguments.bIdentityField ) add identity field by refiltering from all */
		arguments.lArgFields= this.filterColumnList( qMetadata, listAppend( arguments.lArgFields, "pkIdentity" ) );

		if( !listLen( arguments.lFilterFields ) ) {
			request.log( "!!Error: No fields to filter by. [UpsertCrud][#sTableName#]" );
			// throw( message="No fields to filter by.", type="Custom.CFC.CrudGen.UpsertCrud.NoFilterFields" );
			return false;
		} else if( !listLen( arguments.lUpdateFields ) ) {
			request.log( "!!Error: No fields to update. [UpsertCrud][#sTableName#]" );
			// throw( message="No fields to update.", type="Custom.CFC.CrudGen.UpsertCrud.NoUpdateFields" );
			return false;
		} else if( !listLen( arguments.lInsertFields ) ) {
			request.log( "!!Error: No fields to insert. [UpsertCrud][#sTableName#]" );
			// throw( message="No fields to insert.", type="Custom.CFC.CrudGen.UpsertCrud.NoInsertFields" );
			return false;
		}
			
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// this.appendCommentLine( "Upsert a new record into #arguments.sTableName#" );
		// this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" );
		// this.appendDivide();
		// this.appendBlank();
		
		// Here is the meat and bones of it all 
		// this.append( "BEGIN TRANSACTION;" );
		// this.indent();
		// this.appendBlank();
			
		this.append( "DECLARE#this.sTab##this.sTab#@rows INT = 0, @error INT = 0;" );
		this.appendBlank();
		this.appendParamFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	bSelectFields= false
		,	bNewLine= false
		,	sPrefix= arguments.sParamsPrefix
		,	lNullable= arguments.sIdentityField
		);
		this.appendParamFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lUpdateFields
		,	bSelectFields= true
		,	bNewLine= false
		,	sPrefix= arguments.sParamsPrefix
		);
		this.appendBlank();
		if( arguments.bIdentityField ) {
			this.append( '<cfif arguments.#arguments.sIdentityField# IS NOT "null">' );
			this.indent();
		}
		this.append( "UPDATE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" );
		this.append( "SET#this.sTab##this.sTab#" );
		this.appendUpdateFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lUpdateFields
		,	bSelectFields= true
		,	bNewLine= false
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		);
		this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	bSearchFields= false
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		);
		this.append( ";", false );
		this.appendBlank();
		this.append( "SELECT#this.sTab##this.sTab#@rows = @@ROWCOUNT, @error = @@ERROR;" );
		if( arguments.bIdentityField ) {
			this.appendBlank();
			this.append( "IF( @rows > 0 ) SELECT #arguments.sParamsPrefix##arguments.sIdentityField# AS pk_identity;" );
		}
		if( arguments.bIdentityField ) {
			this.unindent();
			this.append( "</cfif>" );
		}
		this.appendBlank();
		// If the record doesn't exist, INSERT 
		this.append( "IF( @rows = 0 AND @error = 0 )" );
		this.appendBegin();
		this.append( "INSERT INTO #this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )# (" );
		this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		);
		this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		);
		this.append( ")" );
		this.append( "VALUES ( " );
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		,	bNullCheck= false
		);
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		,	bNullCheck= false
		);
		this.append( ");" );
		if ( arguments.bIdentityField ) {
			this.appendBlank();
			this.append( "SELECT SCOPE_IDENTITY() AS pk_identity;" );
		}
		this.appendEnd();
		this.appendBlank();

		// this.unindent();
		// this.append( "COMMIT TRANSACTION;" );
		// this.appendBlank();
		// this.appendComment( "Check the transaction for errors and commit or rollback" );

		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= arguments.lOptionalFields;
		// arguments.lArgsOptional= listAppend( arguments.lOptionalFields, arguments.lFilterFields );
		// Store Param definition 
		this.addDefinition( "upsert", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}
</cfscript>