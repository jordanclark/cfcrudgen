
<cffunction name="countCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.countSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!NOTNULL,!COMPARABLE">
<cfargument name="lLikeFields" type="string" default="">
<cfargument name="bSearchFields" type="boolean" default="true">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>

<cfset arguments.lFilterFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>
<cfset arguments.lLikeFields = this.filterColumnList( qMetadata, arguments.lLikeFields )>
<cfset arguments.lArgFields = arguments.lFilterFields>

<cfif NOT listLen( arguments.lFilterFields )>
	<cfset request.log( "!!Error: No fields to filter by. [CountCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.CountCrud.NoFilterFields"
		message="No fields to filter by."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Count the number of records from #arguments.sTableName#" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()> --->

<!--- Here is the meat and bones of it all --->
	
	<!--- <cfset this.appendComment( "Finally grab the records we want" )> --->
	<cfset this.append( "SELECT#this.sTab##this.sTab#COUNT( * ) AS total" )>
	<cfset this.append( "FROM#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
	<cfset this.appendWhereFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	lLikeFields= arguments.lLikeFields
	,	bSearchFields= arguments.bSearchFields
	)>
	<cfset this.append( ";", false )>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = ( arguments.bSearchFields ? arguments.lFilterFields : "" )>

<!--- Store Param definition --->
<cfset this.addDefinition( "count", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>