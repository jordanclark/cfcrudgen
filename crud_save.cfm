
<cffunction name="saveCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.saveSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lInsertFields" type="string" default="!MUTABLE">
<cfargument name="lOptionalFields" type="string" default="!NULL,!MUTABLE">
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

<!--- <cfset request.log( "crud_save args:" )> --->
<!--- <cfset request.log( duplicate( arguments ) )> --->

<!--- <cfif arguments.bIdentityField>
	<!--- add identity field by refiltering from all --->
	<cfset arguments.lArgFields = this.filterColumnList( qMetadata, listAppend( arguments.lArgFields, "pkIdentity" ) )>
</cfif> --->

<cfif NOT listLen( arguments.lFilterFields )>
	<cfset request.log( "!!Error: No fields to filter by. [SaveCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.SaveCrud.NoFilterFields"
		message="No fields to filter by."
	>
<cfelseif NOT listLen( arguments.lUpdateFields )>
	<cfset request.log( "!!Error: No fields to update. [SaveCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.SaveCrud.NoUpdateFields"
		message="No fields to update."
	>
<cfelseif NOT listLen( arguments.lInsertFields )>
	<cfset request.log( "!!Error: No fields to insert. [SaveCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.SaveCrud.NoInsertFields"
		message="No fields to insert."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Save a new record into #arguments.sTableName#" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->

	<cfset this.append( "BEGIN TRANSACTION;" )>
	<cfset this.appendBlank()>
	<cfset this.indent()>
	
	<cfset this.append( "IF EXISTS( " )>
	<cfset this.indent()>
		<cfset this.append( "SELECT#this.sTab##this.sTab#1" )>
		<cfset this.append( "FROM#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
		<cfset this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	bSearchFields= false
		,	bNullCheck= true
		)>
	<cfset this.unindent()>
	<cfset this.append( ")" )>
	
	<!--- Otherwise record exists, UPDATE --->
	<cfset this.appendBegin()>
		<cfset this.append( "DECLARE#this.sTab##this.sTab#@rows INT;" )>
		<cfset this.appendBlank()>
		<cfset this.append( "UPDATE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
		<cfset this.append( "SET#this.sTab##this.sTab#" )>
		<cfset this.appendUpdateFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lUpdateFields
		,	bSelectFields= true
		,	bNewLine= false
		)>
		<cfset this.appendWhereFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lFilterFields
		,	bSearchFields= false
		)>
		<cfset this.append( ";", false )>
		
		<cfif arguments.bIdentityField>
			<cfset this.appendBlank()>
			<!--- <cfset this.append( "SELECT ##arguments.#arguments.sIdentityField### AS pk_identity" )> --->
			<!--- <cfset this.append( "SELECT #this.appendQueryParam( qMetadata, arguments.sIdentityField, true )# AS pk_identity" )> --->
			<cfset this.append( "SELECT <cfif arguments.#arguments.sIdentityField# IS ""null"">NULL<cfelse>##arguments.#arguments.sIdentityField###</cfif> AS pk_identity" )>
		</cfif>
		
	<cfset this.appendEnd()>
	
	<cfset this.append( "ELSE" )>
	
	<!--- If the record doesn't exist, INSERT --->
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
		,	bNullCheck= true
		)>
		<cfset this.appendValueFields(
			qMetadata= qMetadata
		,	sColumnFilter= arguments.lOptionalFields
		,	bAliasFields= false
		,	bOptionalFields= true
		,	bNewLine= true
		,	bNullCheck= true
		)>
		<cfset this.append( ");" )>
		<cfif arguments.bIdentityField>
			<cfset this.appendBlank()>
			<cfset this.append( "SELECT SCOPE_IDENTITY() AS pk_identity;" )>
		</cfif>
	<cfset this.appendEnd()>

	<cfset this.appendBlank()>
		
	<cfset this.unindent()>
	<cfset this.append( "COMMIT TRANSACTION;" )>
	<cfset this.appendBlank()>
	
	<cfset this.appendComment( "Check the transaction for errors and commit or rollback" )>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = arguments.lOptionalFields>
<!--- <cfset arguments.lArgsOptional = listAppend( arguments.lOptionalFields, arguments.lFilterFields )> --->

<!--- Store Param definition --->
<cfset this.addDefinition( "save", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>