
<cffunction name="selectSetCrud" output="true" returnType="string">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.selectSetSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lSetSelectFields" type="string" required="true">
<cfargument name="sOrderBy" type="string" default="">
<cfargument name="bSearchFields" type="boolean" default="false">

<cfset var qMetadata = this.getTableMetadata( arguments.sTableName )>
<cfset var stArgs = {}>
<cfset var sOutput = "">
<cfset var nSetLength = listLen( arguments.lSetSelectFields, "|" )>
<cfset var nCurrentSet = 1>
<cfset var lSets = "">

<cfset arguments.sUdfName = this.camelCase( "db_" & replaceNoCase( arguments.sCrudName, arguments.sCommonName, "" ) )>
<cfset arguments.sCrudName = this.camelCase( arguments.sCrudName )>
<cfset arguments.lSelectFields = "">

<cfset qMetadata= this.addColumnMetadataRow(
	qMetadata= qMetadata
,	sTypeName="int"
,	sColumnName="selectSet"
,	sDefaultValue="1"
,	bPrimaryKeyColumn="0"
,	isNullable="0"
,	isComputed="0"
,	isIdentity="0"
,	isSearchable="0"
)>
<cfset arguments.lArgFields = this.filterColumnList( qMetadata, arguments.lFilterFields )>

<cfif NOT listLen( arguments.lSetSelectFields )>
	<cfset request.log( "!!Error: No fields to filter by. [SelectCrud][#sTableName#]" )>
	<cfreturn>
	<cfthrow type="Custom.CFC.CrudGen.SelectCrud.NoSelectFields"
		message="No fields to select."
	>
</cfif>

<cfset arguments.nSetSelectLength = nSetLength>
<cfset arguments.sSetSelect = arguments.sCrudName>

<cfloop index="nCurrentSet" from="1" to="#nSetLength#">
	<cfset stArgs = duplicate( arguments )>
	<cfset stArgs.sSetSelect = arguments.sCrudName>
	<cfset stArgs.nSetSelectIndex = nCurrentSet>
	<cfset stArgs.sCrudName = arguments.sCrudName & nCurrentSet>
	<cfset stArgs.lSelectFields = listGetAt( arguments.lSetSelectFields, nCurrentSet, "|" )>
	<cfset structDelete( stArgs, "lSetSelectFields" )>
	<cfset structDelete( stArgs, "sQueryTagFileName" )>
	
	<cfset this.selectCrud( argumentcollection = stArgs )>
	<cfset sOutput = sOutput & this.readBuffer( stArgs.sCrudName )>
	<cfset lSets = listAppend( lSets, arguments.sCrudName & nCurrentSet )>
</cfloop>

<!--- <cfoutput>
	SetCOUNT: #SetCount# <br />
</cfoutput>
<cfabort> --->

<cfset arguments.lSetSelects = lSets>
<cfset arguments.qFields = qMetadata>
<cfset arguments.lSelectFields = "">
<cfset arguments.lArgsOptional = ( arguments.bSearchFields ? arguments.lFilterFields : "" )>

<!--- Store Param definition --->
<cfset this.addDefinition( "selectSet", arguments, sOutput )>

<!--- Generate query tag at the same time --->
<cfif structKeyExists( arguments, "sQueryTagFileName" )>
	<!--- <cfset this.generateQueryTag( arguments.sCrudName, arguments.sQueryTagFileName )> --->
	<cfset this.writeDefinition( arguments.sCrudName, arguments.sQueryTagFileName, "CFC" )>
<cfelseif structKeyExists( arguments, "sBaseCfmDir" )>
	<!--- <cfset this.generateQueryTag( arguments.sCrudName, arguments.sQueryTagFileName )> --->
	<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sBaseCfmDir#/#arguments.sCommonName#/dbg_#lCase( arguments.sTableName )#_#lCase( arguments.sCrudName )#.cfm", "CFC" )>
</cfif>

<cfreturn>

</cffunction>