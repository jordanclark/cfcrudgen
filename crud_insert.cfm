<cfscript>
	boolean function insertCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.insertSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lInsertFields= "!MUTABLE"
	,	string lOptionalFields= "!NULL"
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName, "*" );
		if( !qMetadata.recordCount ) {
			return false;
		}
		structAppend( arguments, this.stDefaults, false );
		arguments.bIdentityField= ( listFind( valueList( qMetadata.isIdentity ), 1 ) ? true : false );
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lInsertFields= this.filterColumnList( qMetadata, arguments.lInsertFields );
		arguments.lOptionalFields= this.filterColumnList( qMetadata, arguments.lOptionalFields );
		arguments.lRequiredFields= udf.listRemoveListNoCase( arguments.lInsertFields, arguments.lOptionalFields );
		arguments.lArgFields= arguments.lInsertFields;
		if( !listLen( arguments.lInsertFields ) ) {
			request.log( "!!Error: No fields to insert. [InsertCrud][#sTableName#]" );
			// throw( message="No fields to insert.", type="Custom.CFC.CrudGen.InsertCrud.NoInsertFields" );
			return false;
		}
		// New buffer for crud 
		this.addBuffer( arguments.sCrudName, "sql", true );
		// Build the comments 
		// this.appendBlank();
		// this.appendDivide();
		// this.appendCommentLine( "Insert a new record into #arguments.sTableName#" );
		// this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" );
		// this.appendDivide();
		// this.appendBlank();
		// Here is the meat and bones of it all 
		// this.appendVar( "spname", "sysname", "Object_Name(@@ProcID)", "Store this crud's name" );
		if( arguments.bIdentityField ) {
			this.append( "BEGIN TRANSACTION;" );
			this.appendBlank();
			this.indent();
		}
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
		this.appendLine( "VALUES ( " );
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		,	bNullCheck= false
		);
		this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		,	bNullCheck= true
		);
		this.append( ");" );
		if( arguments.bIdentityField ) {
			this.appendBlank();
			this.append( "SELECT SCOPE_IDENTITY() AS pk_identity;" );
		}
		// only manage transaction if inserting into identity table 
		if( arguments.bIdentityField ) {
			this.unindent();
			this.appendBlank();
			this.append( "COMMIT TRANSACTION;" );
		}
		this.appendBlank();
		arguments.qFields= qMetadata;
		arguments.lArgsOptional= arguments.lOptionalFields;
		// Store Param definition 
		this.addDefinition( "insert", arguments, this.readBuffer( arguments.sCrudName ) );
		// Generate query tag at the same time 
		return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" );
	}
</cfscript>	