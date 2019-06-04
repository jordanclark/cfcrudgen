
<cffunction name="upsertCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.upsertSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lInsertFields" type="string" default="!MUTABLE">
<cfargument name="lOptionalFields" type="string" default="!NULL">
<cfargument name="lUpdateFields" type="string" default="!MUTABLE">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>
<cfset var sTransName = left( replaceNoCase( replace( arguments.sCrudName, "_", "", "all" ), "gsp", "tran_" ), 32 )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset arguments.bIdentityField = ( arrayFind( qMetadata.columnData( "isIdentity" ), 1 ) ? true : false )>
<cfset arguments.sIdentityField = qMetadata.filter( function( r ) { return r.isIdentity IS 1; } ).fieldName>
<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lFilterFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>
<cfset arguments.lInsertFields = this.filterColumnList( qMetadata, arguments.lInsertFields )>
<cfset arguments.lOptionalFields = this.filterColumnList( qMetadata, arguments.lOptionalFields )>
<cfset arguments.lRequiredFields = udf.listRemoveListNoCase( arguments.lInsertFields, arguments.lOptionalFields )>
<cfset arguments.lUpdateFields = udf.listRemoveListNoCase( this.filterColumnList( qMetadata, arguments.lUpdateFields ), arguments.lFilterFields )>
<cfset arguments.lArgFields = listRemoveDuplicates( listAppend( arguments.lFilterFields, arguments.lInsertFields ), ",", true )>
<cfset arguments.sParamsPrefix = "@" & this.getSqlSafeName( listLast( arguments.sTableName, '.' ) ) & "_">

<!--- <cfif arguments.bIdentityField>
	<!--- add identity field by refiltering from all --->
	<cfset arguments.lArgFields = this.filterColumnList( qMetadata, listAppend( arguments.lArgFields, "pkIdentity" ) )>
</cfif> --->

<cfif NOT listLen( arguments.lFilterFields )>
	<cfset request.log( "!!Error: No fields to filter by. [UpsertCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.UpsertCrud.NoFilterFields"
		message="No fields to filter by."
	>
<cfelseif NOT listLen( arguments.lUpdateFields )>
	<cfset request.log( "!!Error: No fields to update. [UpsertCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.UpsertCrud.NoUpdateFields"
		message="No fields to update."
	>
<cfelseif NOT listLen( arguments.lInsertFields )>
	<cfset request.log( "!!Error: No fields to insert. [UpsertCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.UpsertCrud.NoInsertFields"
		message="No fields to insert."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Upsert a new record into #arguments.sTableName#" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	
	<!---
	<cfset this.append( "BEGIN TRANSACTION;" )>
	<cfset this.indent()>
	<cfset this.appendBlank()>
	--->
	
	<cfset this.append( "DECLARE#this.sTab##this.sTab#@rows INT = 0, @error INT = 0;" )>
	<cfset this.appendBlank()>
	<cfset this.appendParamFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	bSelectFields= false
	,	bNewLine= false
	,	sPrefix= arguments.sParamsPrefix
	,	lNullable= arguments.sIdentityField
	)>
	<cfset this.appendParamFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lUpdateFields
	,	bSelectFields= false
	,	bNewLine= false
	,	sPrefix= arguments.sParamsPrefix
	)>
	<cfset this.appendBlank()>

	<cfif arguments.bIdentityField>
		<cfset this.append( "<cfif arguments.#arguments.sIdentityField# IS NOT ""null"">" )>
		<cfset this.indent()>
	</cfif>
	
	<cfset this.append( "UPDATE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
	<cfset this.append( "SET#this.sTab##this.sTab#" )>
	<cfset this.appendUpdateFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lUpdateFields
	,	bSelectFields= true
	,	bNewLine= false
	,	bUseParams= true
	,	sPrefix= arguments.sParamsPrefix
	)>
	<cfset this.appendWhereFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	bSearchFields= false
	,	bUseParams= true
	,	sPrefix= arguments.sParamsPrefix
	)>
	<cfset this.append( ";", false )>
	<cfset this.appendBlank()>
	<cfset this.append( "SELECT#this.sTab##this.sTab#@rows = @@ROWCOUNT, @error = @@ERROR;" )>
	
	<cfif arguments.bIdentityField>
		<cfset this.appendBlank()>
		<cfset this.append( "IF( @rows > 0 ) SELECT #arguments.sParamsPrefix##arguments.sIdentityField# AS pk_identity;" )>
	</cfif>
	
	<cfif arguments.bIdentityField>
		<cfset this.unindent()>
		<cfset this.append( "</cfif>" )>
	</cfif>
	
	<cfset this.appendBlank()>
	
	<!--- If the record doesn't exist, INSERT --->
	<cfset this.append( "IF( @rows = 0 AND @error = 0 )" )>
	<cfset this.appendBegin()>
		<cfset this.append( "INSERT INTO #this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )# (" )>
		<cfset this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		)>
		<cfset this.appendSelectFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		)>
		<cfset this.append( ")" )>
		<cfset this.append( "VALUES ( " )>
		<cfset this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lRequiredFields
		,	bAliasFields= false
		,	bOptionalFields= false
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		,	bNullCheck= false
		)>
		<cfset this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		,	bUseParams= true
		,	sPrefix= arguments.sParamsPrefix
		,	bNullCheck= false
		)>
		<cfset this.append( ");" )>
		<cfif arguments.bIdentityField>
			<cfset this.appendBlank()>
			<cfset this.append( "SELECT SCOPE_IDENTITY() AS pk_identity;" )>
		</cfif>
	<cfset this.appendEnd()>
	
	<cfset this.appendBlank()>
		
	<!---
	<cfset this.unindent()>
	<cfset this.append( "COMMIT TRANSACTION;" )>
	<cfset this.appendBlank()>
	<cfset this.appendComment( "Check the transaction for errors and commit or rollback" )>
	--->
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = arguments.lOptionalFields>
<!--- <cfset arguments.lArgsOptional = listAppend( arguments.lOptionalFields, arguments.lFilterFields )> --->

<!--- Store Param definition --->
<cfset this.addDefinition( "upsert", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>