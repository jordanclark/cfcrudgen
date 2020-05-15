<cfscript>
	boolean function mergeCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.mergeSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!PK"
	,	string lInsertFields= "!MUTABLE"
	,	string lOptionalFields= "NULL"
	,	string lUpdateFields= "!MUTABLE"
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if( !qMetadata.recordCount ) {
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
		// if( arguments.bIdentityField ) {
		// 	// add identity field by refiltering from all 
		// 	arguments.lArgFields= this.filterColumnList( qMetadata, listAppend( arguments.lArgFields, "pkIdentity" ) );
		// }

		if( !listLen( arguments.lFilterFields ) ) {
			request.log( "!!Error: No fields to filter by. [MergeCrud][#sTableName#]" );
			// throw( message="No fields to filter by.", type="Custom.CFC.CrudGen.MergeCrud.NoFilterFields" );
			return false;
		} else if( !listLen( arguments.lUpdateFields ) ) {
			request.log( "!!Error: No fields to update. [MergeCrud][#sTableName#]" );
			// throw( message="No fields to update.", type="Custom.CFC.CrudGen.MergeCrud.NoUpdateFields" );
			return false;
		} else if( !listLen( arguments.lInsertFields ) ) {
			request.log( "!!Error: No fields to insert. [MergeCrud][#sTableName#]" );
			// throw( message="No fields to insert.", type="Custom.CFC.CrudGen.MergeCrud.NoInsertFields" );
			return false;
		}
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// this.appendCommentLine( "Save a new record into #arguments.sTableName#" );
		// this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" );
		// this.appendDivide();
		// this.appendBlank();
		// Here is the meat and bones of it all 
		this.append( "MERGE INTO#this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )# AS target" );
		this.append( "USING#this.sTab##this.sTab#( VALUES (" );
		this.indent( 2 );
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		,	bNullCheck= true
		);
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		,	bNullCheck= true
		);
		this.unindent();
		this.append( this.sTab & ") )" );
		this.append( this.sTab & "AS source (" );
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
		this.unindent();
		this.append( this.sTab & ")" );
		this.unindent();
		this.appendConditionMatch(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	sLeftPrefix="target."
		,	sRightPrefix="source."
		);
		this.unindent( 2 );
		this.append( "WHEN MATCHED THEN" );
		this.indent();
		this.append( "UPDATE SET" );
		this.appendUpdateFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bSelectFields= false
		,	bNewLine= false
		,	bRowUpdate= false
		,	bUseParams= true
		,	sPrefix="source."
		,	bOptionalFields= false
		);
		this.appendUpdateFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bSelectFields= true
		,	bNewLine= false
		,	bRowUpdate= false
		,	bUseParams= true
		,	sPrefix="source."
		,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
		);
		this.unindent();
		this.append( "WHEN NOT MATCHED BY TARGET THEN" );
		this.indent();
		this.append( "INSERT (" );
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
		,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
		,	bNewLine= true
		);
		this.append( ")" );
		this.append( "VALUES (" );
		this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix="source."
		);
		this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix="source."
		);
		this.append( ")" );
		if ( arguments.bIdentityField ) {
			this.append( "OUTPUT INSERTED.#sIdentityField# AS pk_identity" );
		}
		this.unindent();
		this.append( ";" );
		
		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= arguments.lOptionalFields;
		// arguments.lArgsOptional= listAppend( arguments.lOptionalFields, arguments.lFilterFields );
		// Store Param definition 
		this.addDefinition( "merge", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}
</cfscript>