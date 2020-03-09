
<cffunction name="insertCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.insertSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lInsertFields" type="string" default="!MUTABLE">
<cfargument name="lOptionalFields" type="string" default="!NULL">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName, "*" )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset arguments.bIdentityField = ( listFind( valueList( qMetadata.isIdentity ), 1 ) ? true : false )>
<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lInsertFields = this.filterColumnList( qMetadata, arguments.lInsertFields )>
<cfset arguments.lOptionalFields = this.filterColumnList( qMetadata, arguments.lOptionalFields )>
<cfset arguments.lRequiredFields = udf.listRemoveListNoCase( arguments.lInsertFields, arguments.lOptionalFields )>
<cfset arguments.lArgFields = arguments.lInsertFields>

<cfif NOT listLen( arguments.lInsertFields )>
	<cfset request.log( "!!Error: No fields to insert. [InsertCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.InsertCrud.NoInsertFields"
		message="No fields to insert."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Insert a new record into #arguments.sTableName#" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lInsertFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	<!--- <cfset this.appendVar( "spname", "sysname", "Object_Name(@@ProcID)", "Store this crud's name" )> --->
	<cfif arguments.bIdentityField>
		<cfset this.append( "BEGIN TRANSACTION;" )>
		<cfset this.appendBlank()>
		<cfset this.indent()>
	</cfif>

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
	<cfset this.appendLine( "VALUES ( " )>
	<cfset this.appendValueFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lRequiredFields
	,	bAliasFields= false
	,	bOptionalFields= false
	,	bNewLine= true
	,	bNullCheck= false
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
	
	<!--- only manage transaction if inserting into identity table --->
	<cfif arguments.bIdentityField>
		<cfset this.unindent()>
		<cfset this.appendBlank()>
		<cfset this.append( "COMMIT TRANSACTION;" )>
	</cfif>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = arguments.lOptionalFields>

<!--- Store Param definition --->
<cfset this.addDefinition( "insert", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>