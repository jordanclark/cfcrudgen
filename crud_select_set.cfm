<cfscript>
	boolean function selectSetCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.selectSetSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!PK"
	,	required string lSetSelectFields
	,	string sOrderBy= ""
	,	boolean bSearchFields= false
	) {
		var qMetadata= this.getTableMetadata( arguments.sTableName );
		if( !qMetadata.recordCount ) {
			return false;
		}
		var stArgs= {};
		var sOutput= "";
		var nSetLength= listLen( arguments.lSetSelectFields, "|" );
		var nCurrentSet= 1;
		var lSets= "";
		arguments.sUdfName= this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) );
		arguments.sCrudName= this.camelCase( arguments.sCrudName );
		arguments.lSelectFields= "";
		qMetadata= this.addColumnMetadataRow(
			qMetadata= qMetadata
		,	sTypeName="int"
		,	sColumnName="selectSet"
		,	sDefaultValue="1"
		,	bPrimaryKeyColumn="0"
		,	isNullable="0"
		,	isComputed="0"
		,	isIdentity="0"
		,	isSearchable="0"
		);
		arguments.lArgFields= this.filterColumnList( qMetadata, arguments.lFilterFields );
		if( !listLen( arguments.lSetSelectFields ) ) {
			request.log( "!!Error: No fields to filter by. [SelectCrud][#sTableName#]" );
			// throw( message="No fields to select.", type="Custom.CFC.CrudGen.SelectCrud.NoSelectFields" );
			return false;
		}
		arguments.nSetSelectLength= nSetLength;
		arguments.sSetSelect= arguments.sCrudName;
		for( nCurrentSet=1; nCurrentSet<=nSetLength; nCurrentSet++ ) {
			stArgs= duplicate( arguments );
			stArgs.sSetSelect= arguments.sCrudName;
			stArgs.nSetSelectIndex= nCurrentSet;
			stArgs.sCrudName= arguments.sCrudName & nCurrentSet;
			stArgs.lSelectFields= listGetAt( arguments.lSetSelectFields, nCurrentSet, "|" );
			structDelete( stArgs, "lSetSelectFields" );
			structDelete( stArgs, "sQueryTagFileName" );
			this.selectCrud( argumentcollection= stArgs );
			sOutput= sOutput & this.readBuffer( stArgs.sCrudName );
			lSets= listAppend( lSets, arguments.sCrudName & nCurrentSet );
		}
		arguments.lSetSelects= lSets;
		arguments.qFields= qMetadata;
		arguments.lSelectFields= "";
		arguments.lArgsOptional= ( arguments.bSearchFields ? arguments.lFilterFields : "" );
		// Store Param definition 
		this.addDefinition( "selectSet", arguments, sOutput );
		// Generate query tag at the same time 
		if( structKeyExists( arguments, "sQueryTagFileName" ) ) {
			return this.writeDefinition( arguments.sCrudName, arguments.sQueryTagFileName, "CFC" );
		} else if( structKeyExists( arguments, "sBaseCfmDir" ) ) {
			return this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/dbg_#lCase( arguments.sTableName )#_#lCase( arguments.sCrudName )#.cfm", "CFC" );
		}
		return true;
	}
</cfscript>