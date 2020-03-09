
<cffunction name="paginateCrud" output="false">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.paginateSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!NOTNULL,!COMPARABLE">
<cfargument name="lSelectFields" type="string" default="*">
<cfargument name="lLikeFields" type="string" default="">
<cfargument name="sOrderBy" type="string" default="!PK">
<cfargument name="bSearchFields" type="boolean" default="true">
<cfargument name="sType" type="string" default="paginate">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>

<cfset structAppend( arguments, this.stDefaults, false )>

<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lFilterFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>
<cfset arguments.lSelectFields = this.filterColumnList( qMetadata, arguments.lSelectFields )>
<cfset arguments.lLikeFields = this.filterColumnList( qMetadata, arguments.lLikeFields )>
<cfset arguments.sOrderBy = this.filterColumnList( qMetadata, arguments.sOrderBy ) & " DESC">
<cfset arguments.lArgFields = arguments.lFilterFields>
<cfset arguments.bRowLimit = false>

<cfif NOT listLen( arguments.lSelectFields )>
	<cfset request.log( "!!Error: No fields to filter by. [PaginateCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.PaginateCrud.NoSelectFields"
		message="No fields to select."
	>
</cfif>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfif listLen( arguments.lFilterFields )>
	<cfset this.appendCommentLine( "Select a single record from #uCase( arguments.sTableName )#" )>
	<cfset this.appendCommentLine( "based on fields: #uCase( replace( arguments.lFilterFields, ',', ', ', 'all' ) )#" )>
<cfelse>
	<cfset this.appendCommentLine( "Select ALL records from #uCase( arguments.sTableName )#" )>
</cfif>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	
	<cfset this.appendLine( "SELECT#this.sTab#" )>
	<cfif arguments.bRowLimit>
		<cfset this.appendOn( "#this.sTab#<cfif arguments.rows GT 0>TOP (##arguments.rows##)</cfif>" )>
	</cfif>
	<!--- <cfset this.append( this.sTab & this.sTab )> --->
	<cfset this.appendSelectFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lSelectFields
	,	bAliasFields= true
	,	bSearchFields= false
	,	bNewLine= arguments.bRowLimit
	)>
	<cfset this.append( "FROM#this.sTab##this.sTab##this.tablePrefix##this.getSqlSafeName( listLast( arguments.sTableName, '.' ) )#" )>
	<cfset this.appendWhereFields(
		qMetadata= qMetadata
	,	sColumnFilter= arguments.lFilterFields
	,	lLikeFields= arguments.lLikeFields
	,	bSearchFields= arguments.bSearchFields
	)>
	<cfif len( arguments.sOrderBy )>
		<cfset this.append( "ORDER BY#this.sTab##arguments.sOrderBy#" )>
	</cfif>
	<cfset this.appendLine( 'OFFSET <cfqueryparam value="##arguments.pageSize##" cfSqlType="integer"> * (<cfqueryparam value="##arguments.page##" cfSqlType="integer"> - 1) ROWS' )>
	<cfset this.appendLine( 'FETCH NEXT <cfqueryparam value="##arguments.pageSize##" cfSqlType="integer"> ROWS ONLY' )>
	<cfset this.append( ";", false )>
	
<cfset this.appendBlank()>

<cfset arguments.qFields = qMetadata>
<cfset arguments.lArgsOptional = ( arguments.bSearchFields ? arguments.lFilterFields : "" )>

<!--- Store Param definition --->
<cfset this.addDefinition( arguments.sType, arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/#arguments.sFileName#", "CFC" )>

<cfreturn>

</cffunction>