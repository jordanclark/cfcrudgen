
<cffunction name="deleteCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.deleteSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lLikeFields" type="string" default="">
<cfargument name="bSearchFields" type="boolean" default="false">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lFilterFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>	
<cfset arguments.lLikeFields = this.filterColumnList( qMetadata, arguments.lLikeFields )>
<cfset arguments.lArgFields = arguments.lFilterFields>

<cfif NOT listLen( arguments.lFilterFields )>
	<cfset request.log( "!!Error: No fields to filter by. [DeleteCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.DeleteCrud.NoFilterFields"
		message="No fields to filter by."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfif listLen( arguments.lFilterFields )>
	<cfset this.appendCommentLine( "Delete a single record from #arguments.sTableName#" )>
	<cfset this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" )>
<cfelse>
	<cfset this.appendCommentLine( "Delete ALL records from #arguments.sTableName#" )>
</cfif>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	
	<cfset this.append( "DELETE#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
	<cfset appendWhereFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	lLikeFields= arguments.lLikeFields
	,	bSearchFields= arguments.bSearchFields
	)>
	<cfset this.append( ";", false )>
	
	<cfset this.appendBlank()>
	<cfset this.append( "SELECT#this.sTab##this.sTab#@@ROWCOUNT AS row_count;" )>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = ( arguments.bSearchFields ? arguments.lFilterFields : "" )>

<!--- Store Param definition --->
<cfset this.addDefinition( "delete", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>


<cfreturn>

</cffunction>
