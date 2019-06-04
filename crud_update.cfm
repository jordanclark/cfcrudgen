
<cffunction name="updateCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.updateSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lLikeFields" type="string" default="">
<cfargument name="lUpdateFields" type="string" default="*">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset request.log( "!!UPDATE FILTER FIELD: [#arguments.lFilterFields#][#arguments.lUpdateFields#]" )>

<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lFilterFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>
<cfset arguments.lLikeFields = this.filterColumnList( qMetadata, arguments.lLikeFields )>
<cfset arguments.lUpdateFields = this.filterColumnList( qMetadata, arguments.lUpdateFields )>
<cfset arguments.lUpdateFields = this.filterColumnList( qMetadata, udf.listRemoveListNoCase( arguments.lUpdateFields, arguments.lFilterFields ) )>
<cfset arguments.lArgFields = this.filterColumnList( qMetadata, listAppend( arguments.lFilterFields, arguments.lUpdateFields ) )>

<cfset request.log( "!!UPDATE FILTER FIELD: [#arguments.lFilterFields#][#arguments.lUpdateFields#]" )>

<cfif NOT listLen( arguments.lUpdateFields )>
	<cfset request.log( "!!Error: No fields to update. [UpdateCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.UpdateCrud.NoUpdateFields"
		message="No fields to update."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfif listLen( arguments.lFilterFields )>
	<cfset this.appendCommentLine( "Update a single record from #arguments.sTableName#" )>
	<cfset this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" )>
<cfelse>
	<cfset this.appendCommentLine( "Update ALL records from #arguments.sTableName#" )>
</cfif>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	
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
	,	lLikeFields= arguments.lLikeFields
	,	bSearchFields= false
	)>
	<cfset this.append( ";", false )>
	
	<cfset this.appendBlank()>
	<cfset this.append( "SELECT#this.sTab##this.sTab#@@ROWCOUNT AS row_count;" )>
	<!--- <cfset this.appendErrorCheck()> --->

<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = arguments.lUpdateFields>

<!--- Store Param definition --->
<cfset this.addDefinition( "update", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>
