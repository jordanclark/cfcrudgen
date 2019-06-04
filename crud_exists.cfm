
<cffunction name="existsCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.existsSuffix#">
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
	<cfset request.log( "!!Error: No fields to filter by. [ExistsCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.ExistsCrud.NoFilterFields"
		message="No fields to filter by."
	>
</cfif>

<!--- add identity field by refiltering from all --->
<cfset arguments.lArgsOptional = arguments.bSearchFields>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Count the number of records from #arguments.sTableName#" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	
	<!--- <cfset this.appendComment( "Finally grab the records we want" )> --->
	<cfset this.append( "SELECT#this.sTab##this.sTab#CONVERT( bit, 1 )" )>
	<cfset this.append( "FROM#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
	<cfset appendWhereFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	lLikeFields= arguments.lLikeFields
	,	bSearchFields= arguments.bSearchFields
	)>
	<cfset this.append( ";", false )>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = ( arguments.bSearchFields ? arguments.lFilterFields : "" )>

<!--- Store Param definition --->
<cfset this.addDefinition( "exists", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>


<cfreturn>

</cffunction>