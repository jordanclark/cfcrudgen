
<cffunction name="mergeCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.mergeSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lInsertFields" type="string" default="!MUTABLE">
<cfargument name="lOptionalFields" type="string" default="NULL">
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

<!--- <cfif arguments.bIdentityField>
	<!--- add identity field by refiltering from all --->
	<cfset arguments.lArgFields = this.filterColumnList( qMetadata, listAppend( arguments.lArgFields, "pkIdentity" ) )>
</cfif> --->

<cfif NOT listLen( arguments.lFilterFields )>
	<cfset request.log( "!!Error: No fields to filter by. [MergeCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.MergeCrud.NoFilterFields"
		message="No fields to filter by."
	>
<cfelseif NOT listLen( arguments.lUpdateFields )>
	<cfset request.log( "!!Error: No fields to update. [MergeCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.MergeCrud.NoUpdateFields"
		message="No fields to update."
	>
<cfelseif NOT listLen( arguments.lInsertFields )>
	<cfset request.log( "!!Error: No fields to insert. [MergeCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.MergeCrud.NoInsertFields"
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
	
	<cfset this.append( "MERGE INTO#this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )# AS target" )>
	<cfset this.append( "USING#this.sTab##this.sTab#( VALUES (" )>
	<cfset this.indent( 2 )>
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
	<cfset this.unindent()>
	<cfset this.append( this.sTab & ") )" )>
	<cfset this.append( this.sTab & "AS source (" )>
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
	<cfset this.unindent()>
	<cfset this.append( this.sTab & ")" )>
	<cfset this.unindent()>
	<cfset this.appendConditionMatch(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	sLeftPrefix="target."
	,	sRightPrefix="source."
	)>
	<cfset this.unindent( 2 )>
	<cfset this.append( "WHEN MATCHED THEN" )>
	<cfset this.indent()>
	<cfset this.append( "UPDATE SET" )>
	<cfset this.appendUpdateFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lRequiredFields
	,	bSelectFields= false
	,	bNewLine= false
	,	bRowUpdate= false
	,	bUseParams= true
	,	sPrefix="source."
	,	bOptionalFields= false
	)>
	<cfset this.appendUpdateFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lOptionalFields
	,	bSelectFields= true
	,	bNewLine= false
	,	bRowUpdate= false
	,	bUseParams= true
	,	sPrefix="source."
	,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
	)>
	<cfset this.unindent()>
	<cfset this.append( "WHEN NOT MATCHED BY TARGET THEN" )>
	<cfset this.indent()>
	<cfset this.append( "INSERT (" )>
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
	,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
	,	bNewLine= true
	)>
	<cfset this.append( ")" )>
	<cfset this.append( "VALUES (" )>
	<cfset this.appendSelectFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lRequiredFields
	,	bAliasFields= false
	,	bOptionalFields= false
	,	bNewLine= true
	,	bUseParams= true
	,	sPrefix="source."
	)>
	<cfset this.appendSelectFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lOptionalFields
	,	bAliasFields= false
	,	bOptionalFields="#( len( arguments.lRequiredFields ) )#"
	,	bNewLine= true
	,	bUseParams= true
	,	sPrefix="source."
	)>
	<cfset this.append( ")" )>
	<cfif arguments.bIdentityField>
		<cfset this.append( "OUTPUT INSERTED.#sIdentityField# AS pk_identity" )>
	</cfif>
	<cfset this.unindent()>
	<cfset this.append( ";" )>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = arguments.lOptionalFields>
<!--- <cfset arguments.lArgsOptional = listAppend( arguments.lOptionalFields, arguments.lFilterFields )> --->

<!--- Store Param definition --->
<cfset this.addDefinition( "merge", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>