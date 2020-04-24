<!--- Copyright 2005 Imagineering Internet Inc. (imagineer.ca) and Jordan Clark (jclark@imagineeringstuido.com). All rights reserved.
Use of source and redistribution, with or without modification, are prohibited without prior written consent. --->

<cfcomponent output="false" displayName="crudGen">

<cfproperty name="owner" type="string" default="dbo">
<cfproperty name="dsn" type="string" default="">

<!--- DEFAULT SETTINGS --->
<cfproperty name="crudPrefix" type="string" default="db_" required="true" hint="Default Crud Prefix">
<cfproperty name="updateSuffix" type="string" default="Update" required="true" hint="Default Update Crud Suffix">
<cfproperty name="selectSuffix" type="string" default="Select" required="true" hint="Default Select Crud Suffix">
<cfproperty name="paginateSuffix" type="string" default="Paginate" required="true" hint="Default Select Crud Suffix">
<cfproperty name="insertSuffix" type="string" default="Insert" required="true" hint="Default Insert Crud Suffix">
<cfproperty name="deleteSuffix" type="string" default="Delete" required="true" hint="Default Delete Crud Suffix">
<cfproperty name="removeSuffix" type="string" default="Remove" required="true" hint="Default Remove Crud Suffix">
<cfproperty name="countSuffix" type="string" default="Count" required="true" hint="Default Count Crud Suffix">
<cfproperty name="existsSuffix" type="string" default="Exists" required="true" hint="Default Exists Crud Suffix">
<cfproperty name="saveSuffix" type="string" default="Save" required="true" hint="Default Save Crud Suffix">
<cfproperty name="upsertSuffix" type="string" default="Upsert" required="true" hint="Default Upsert Crud Suffix">
<cfproperty name="mergeSuffix" type="string" default="Merge" required="true" hint="Default Merge Crud Suffix">
<cfproperty name="recordSuffix" type="string" default="Set" required="true" hint="Default Record Crud Suffix">
<cfproperty name="setSuffix" type="string" default="Set" required="true" hint="Default Set Crud Suffix">
<cfproperty name="allSuffix" type="string" default="All" required="true" hint="Default 'All' Crud Suffix">
<cfproperty name="udfPrefix" type="string" default="db" required="true" hint="Default UDF Prefix">


<!-----------------------------------------------------------------------------------------------------------
-- INIT INTERNAL PROPERTIES
------------------------------------------------------------------------------------------------------------>


<cffunction name="init" output="false">
	<cfset this.owner= "dbo">
	<cfset this.db= "">
	<cfset this.crudPrefix= "db_">
	<cfset this.updateSuffix= "_Update">
	<cfset this.selectSuffix= "_Select">
	<cfset this.selectSetSuffix= "_SelectSet">
	<cfset this.selectAllSuffix= "_SelectAll">
	<cfset this.selectRecordSuffix= "_Record">
	<cfset this.paginateSuffix= "_Paginate">
	<cfset this.insertSuffix= "_Insert">
	<cfset this.deleteSuffix= "_Delete">
	<cfset this.deleteAllSuffix= "_Delete_All">
	<cfset this.removeSuffix= "_Remove">
	<cfset this.countSuffix= "_Count">
	<cfset this.existsSuffix= "_Exists">
	<cfset this.saveSuffix= "_Save">
	<cfset this.upsertSuffix= "_Upsert">
	<cfset this.mergeSuffix= "_Merge">
	<cfset this.udfPrefix= "db">
	<cfset this.tablePrefix= "">
	<cfif len( this.owner )>
		<cfset this.tablePrefix= "#this.owner#." & this.tablePrefix>
	</cfif>
	<cfif len( this.db )>
		<cfset this.tablePrefix= "#this.db#." & this.tablePrefix>
	</cfif>
	
	<cfset this.stCommonArgs= {}>
	<cfset this.nIndent= 0>
	<cfset this.sTab= chr( 9 )> 
	<cfset this.sNewLine= chr( 13 ) & chr( 10 )>
	<cfset this.stDefaults= {}>
	
	<cfset this.clearBuffers()>
	
	<cfreturn this>
</cffunction>


<cffunction name="setProperties" output="false">
	<cfset var sKey= "">
	<cfset var fHolder= "">
	
	<cfloop item="sKey" collection="#arguments#">
		<!--- if there is a setter method for this item, pass in the argument to set --->
		<cfif structKeyExists( this, "set" & sKey ) AND isCustomFunction( this[ "set" & sKey ] )>
			<cfset fHolder= this[ "set" & sKey ]>
			<cfset fHolder( arguments[ sKey ] )>
		
		<!--- otherwise just set the property value directly --->
		<cfelse>
			<cfset this[ sKey ]= arguments[ sKey ]>
		</cfif>
	</cfloop>
	
	<cfreturn>
</cffunction>


<cffunction name="setDefaults" output="false">
	<cfset structAppend( this.stDefaults, arguments, true )>
	
	<cfreturn>
</cffunction>


<cfinclude template="write_definition.cfm">
<cfinclude template="query_cfc.cfm">
<cfinclude template="query_tag.cfm">


<!-----------------------------------------------------------------------------------------------------------
-- STORED PROCEDURE GENERATION METHODS
------------------------------------------------------------------------------------------------------------>

<cfinclude template="crud_count.cfm">
<cfinclude template="crud_delete.cfm">
<cfinclude template="crud_delete_all.cfm">
<cfinclude template="crud_exists.cfm">
<cfinclude template="crud_insert.cfm">
<cfinclude template="crud_remove.cfm">
<cfinclude template="crud_save.cfm">
<cfinclude template="crud_select.cfm">
<cfinclude template="crud_paginate.cfm">
<cfinclude template="crud_select_record.cfm">
<cfinclude template="crud_select_all.cfm">
<cfinclude template="crud_select_set.cfm">
<cfinclude template="crud_update.cfm">

<cfinclude template="crud_upsert.cfm">
<cfinclude template="crud_merge.cfm">

<!-----------------------------------------------------------------------------------------------------------
-- METHODS TO APPEND DATA TO THE BUFFER
------------------------------------------------------------------------------------------------------------>


<cffunction name="append" access="package" output="false">
	<cfargument name="sInput" type="string" required="true">
	<cfargument name="bNewLine" type="boolean" default="true">
	<cfargument name="nIndent" type="numeric" default="0">
	
	<!--- adjust indentation --->
	<cfif arguments.nIndent IS NOT 0>
		<cfset this.addIndent( arguments.nIndent )>
	</cfif>
	
	<!--- add a line break --->
	<cfif arguments.bNewLine>
		<cfset arguments.sInput= this.sNewLine & repeatString( this.sTab, this.nIndent ) & arguments.sInput>
	</cfif>
	
	<cfset this.stBuffer[ this.sCurrentBuffer ]= this.stBuffer[ this.sCurrentBuffer ] & arguments.sInput>
	<cfreturn>
</cffunction>


<cffunction name="appendOn" access="package" output="false">
	<cfargument name="sInput" type="string" required="true">
	<cfargument name="nIndent" type="numeric" default="0">
	
	<cfset this.append( arguments.sInput, false, arguments.nIndent )>
	
	<cfreturn>
</cffunction>

	
<cffunction name="appendLine" access="package" output="false">
	<cfargument name="sInput" type="string" required="true">
	<cfargument name="nIndent" type="numeric" default="0">
	
	<cfset this.append( arguments.sInput, true, arguments.nIndent )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendBlank" access="package" output="false">
	<cfset this.append( "" )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendTab" access="package" output="false">
	<cfset this.append( this.sTab, false )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendBegin" access="package" output="false">
	<cfset this.append( "BEGIN;" )>
	<cfset this.indent()>
	
	<cfreturn>
</cffunction>


<cffunction name="appendEnd" access="package" output="false">
	<cfset this.unindent()>
	<cfset this.append( "END;" )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendHeader" access="package" output="false">
	<!--- add the standard 'header' buffer --->
	<cfset this.addBuffer( "header", "sql", false )>
	
	<cfset this.appendBlank()>
	
	<cfreturn>
</cffunction>


<cffunction name="appendDivide" access="package" output="false">
	<cfset this.append( "<!" & "--- " & repeatString( '-', 110 ) & " ---" & ">" )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendEmptyLine" access="package" output="false">
	<cfset this.append( "<!" & "--- " & repeatString( ' ', 110 ) & " ---" & ">" )>
	
	<cfreturn>
</cffunction>


<cffunction name="appendCommentLine" access="package" output="false">
	<cfargument name="sInput" type="string" required="true">
	
	<cfset this.append( "<!" & "--- " & lJustify( arguments.sInput, 110 ) & " ---" & ">" )>
	<cfreturn>
</cffunction>


<cffunction name="appendComment" access="package" output="false">
	<cfargument name="sInput" type="string" required="true">
	
	<cfset this.append( "<!" & "--- " & arguments.sInput & " ---" & ">" )>
	<cfreturn>
</cffunction>


<cffunction name="appendSelectFields" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="bAliasFields" type="boolean" default="false">
	<cfargument name="bOptionalFields" type="boolean" default="false">
	<cfargument name="bNewLine" type="boolean" default="true">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var sFieldAdd= "">
	
	<cfif arguments.bOptionalFields>		
		<cfset sFieldAdd= "#this.sTab#,#this.sTab#">
	<cfelseif bNewLine>
		<cfset sFieldAdd= "#this.sTab##this.sTab#">
	</cfif>
	
	<cfloop query="q">
		<cfif arguments.bOptionalFields AND q.nullable>
			<cfset this.appendLine( '<cfif len( arguments.#q.fieldName# )>' )>
		</cfif>
			<cfif arguments.bAliasFields AND q.sColumnName IS NOT q.fieldName>
				<cfset this.append( "#sFieldAdd##this.sTab##lJustify( q.sColumnNameSafe, 25 )# AS #q.fieldName#", arguments.bNewLine )>
			<cfelse>
				<cfset this.append( "#sFieldAdd##this.sTab##q.sColumnNameSafe#", arguments.bNewLine )>
			</cfif>
			<cfset sFieldAdd= "#this.sTab#,#this.sTab#">
			<cfset arguments.bNewLine= true>
		<cfif arguments.bOptionalFields AND q.nullable>
			<cfset this.appendLine( '</cfif>' )>
		</cfif>
	</cfloop>
	
	<cfreturn>
</cffunction>



<cffunction name="appendValueFields" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="bOptionalFields" type="boolean" default="false">
	<cfargument name="bNewLine" type="boolean" default="true">
	<cfargument name="bUseParams" type="boolean" default="false">
	<cfargument name="sPrefix" type="string" default="@">
	<cfargument name="bNullCheck" type="boolean" default="false">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var sFieldAdd= "#this.sTab##this.sTab##this.sTab#">
	
	<cfif arguments.bOptionalFields>		
		<cfset sFieldAdd= "#this.sTab#,#this.sTab##this.sTab#">
	</cfif>
	
	<cfloop query="q">
		<!--- Loop over the individual crud params --->
		<cfif arguments.bOptionalFields AND q.nullable>
			<cfset this.appendLine( '<cfif len( arguments.#q.fieldName# )>' )>
			<cfif arguments.bUseParams>
				<cfset this.appendLine( sFieldAdd & arguments.sPrefix & q.sColumnName )>
			<cfelse>
				<cfset this.appendLine( sFieldAdd & this.appendQueryParam( q, q.sColumnName, arguments.bNullCheck ) )>
			</cfif>
			<cfset this.appendLine( '</cfif>' )>
		<cfelse>
			<cfif arguments.bUseParams>
				<cfset this.appendLine( sFieldAdd & arguments.sPrefix & q.sColumnName )>
			<cfelse>
				<cfset this.appendLine( sFieldAdd & this.appendQueryParam( q, q.sColumnName, arguments.bNullCheck ) )>
			</cfif>
		</cfif>
		<cfset sFieldAdd= "#this.sTab#,#this.sTab##this.sTab#">
	</cfloop>
	
	<cfreturn>
</cffunction>


<cffunction name="appendParamFields" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="bSelectFields" type="boolean" default="false">
	<cfargument name="sPrefix" type="string" default="@">
	<cfargument name="lNullable" type="string" default="">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var bNull= false>
	<cfset var sqlType= "">

	<cfloop query="q">
		<cfset bNull= ( q.nullable OR listFindNoCase( arguments.lNullable, q.fieldName ) )>
		<!--- Loop over the individual crud params --->
		<cfif arguments.bSelectFields AND bNull>
			<cfset this.appendLine( "<cfif len( arguments.#q.fieldName# )>" )>
		</cfif>
		<cfset sqlType= uCase( q.sqlType )>
		<cfif q.nColumnLength IS -1 AND listFindNoCase( "varchar,nvarchar", sqlType )>
			<cfset sqlType &= "(MAX)">
		<cfelseif listFindNoCase( "decimal", sqlType )>
			<cfset sqlType &= "(#q.nColumnPrecision#,#q.nColumnScale#)">
		<cfelseif q.nColumnLength GT 0>
			<cfset sqlType &= "(#q.maxLength#)">
		</cfif>
		<cfset this.appendLine( ( arguments.bSelectFields ? this.sTab : "" )
				& "DECLARE" & this.sTab & arguments.sPrefix & q.sColumnName & " " & sqlType & "= "
				& this.appendQueryParam( q, q.sColumnName, bNull ) & ";" )>
		<cfif arguments.bSelectFields AND bNull>
			<cfset this.appendLine( "</cfif>" )>
		</cfif>
	</cfloop>
	
	<cfreturn>
</cffunction>


<cffunction name="appendUpdateFields" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="bSelectFields" type="boolean" default="false">
	<cfargument name="bNewLine" type="boolean" default="true">
	<cfargument name="bRowUpdate" type="boolean" default="true">
	<cfargument name="bUseParams" type="boolean" default="false">
	<cfargument name="sPrefix" type="string" default="@">
	<cfargument name="bOptionalFields" type="boolean" default="false">
	<cfargument name="bCommaAppend" type="boolean" default="false">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var sFieldAdd= "">
	<cfset var bNull= false>
	
	<cfif arguments.bRowUpdate>
		<cfset this.append( "#this.sTab#@rows = 0", arguments.bNewLine )>
		<cfset sFieldAdd= "#this.sTab#,#this.sTab##this.sTab#">
	<cfelseif arguments.bOptionalFields>
		<cfset sFieldAdd= "#this.sTab#,#this.sTab##this.sTab#">
	<cfelse>
		<cfset sFieldAdd= "#this.sTab##this.sTab##this.sTab#">
	</cfif>

	<cfloop query="q">
		<cfset bNull= q.nullable>
		<!--- Loop over the individual crud params --->
		<cfif arguments.bSelectFields>
			<cfset this.appendLine( "<cfif len( arguments.#q.fieldName# )>" )>
		</cfif>
		<cfif arguments.bUseParams>
			<cfset this.appendLine( sFieldAdd & q.sColumnNameSafe & " = " & arguments.sPrefix & q.sColumnName )>
		<cfelse>
			<cfset this.appendLine( sFieldAdd & q.sColumnNameSafe & " = " & this.appendQueryParam( q, q.sColumnName, bNull ) )>
		</cfif>
		<cfif arguments.bSelectFields>
			<cfset this.appendLine( "</cfif>" )>
		</cfif>
		<cfset sFieldAdd= "#this.sTab#,#this.sTab##this.sTab#">
	</cfloop>
	
	<cfreturn>
</cffunction>


<cffunction name="appendWhereFields" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="lLikeFields" type="string" default="false">
	<cfargument name="bSearchFields" type="boolean" default="false">
	<cfargument name="bNullCheck" type="boolean" default="false">
	<cfargument name="bUseParams" type="boolean" default="false">
	<cfargument name="sPrefix" type="string" default="@">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var sWhereAdd= "">
	<cfset var bNull= false>
	
	<cfif arguments.bSearchFields>		
		<cfset this.appendLine( "WHERE#this.sTab##this.sTab#(0=0)" )>
		<cfset sWhereAdd= "#this.sTab#AND#this.sTab#">
	<cfelse>
		<cfset sWhereAdd= "WHERE#this.sTab#">
	</cfif>
	
	<cfloop query="q">
		<!--- Loop over the individual crud params --->
		<cfif arguments.bSearchFields>
			<cfset this.appendLine( '<cfif len( arguments.#q.fieldName# )>' )>
		</cfif>
			<cfset this.append( sWhereAdd )>
			<cfset this.appendOn( this.sTab & "(" & q.sColumnNameSafe )>
			<cfif listFindNoCase( arguments.lLikeFields, q.sColumnName )>
				<cfset this.appendOn( " LIKE " )>
			<cfelse>
				<cfset this.appendOn( " = " )>
			</cfif>
			<cfif arguments.bUseParams>
				<cfset this.appendOn( arguments.sPrefix & q.sColumnName )>
			<cfelse>
				<cfset this.appendOn( this.appendQueryParam( q, q.sColumnName, ( bNull OR arguments.bNullCheck ) ) )>
			</cfif>
			<cfset this.appendOn( ")" )>
		<cfif arguments.bSearchFields>
			<cfset this.appendLine( '</cfif>' )>
		</cfif>
		<cfif arguments.bSearchFields>	
			<cfset sWhereAdd= "#this.sTab#AND#this.sTab#">
		<cfelse>
			<cfset sWhereAdd= "#this.sTab#AND#this.sTab##this.sTab#">
		</cfif>
	</cfloop>
	
	<cfreturn>
</cffunction>


<cffunction name="appendConditionMatch" access="package" output="false">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumnFilter" type="string" required="true">
	<cfargument name="sLeftPrefix" type="string" default="">
	<cfargument name="sRightPrefix" type="string" default="">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sColumnFilter )>
	<cfset var sAdd= "ON" & this.sTab>
	
	<cfloop query="q">
		<cfset this.appendLine( sAdd & this.sTab )>
		<cfset this.appendOn( "(#arguments.sLeftPrefix##q.sColumnNameSafe# = #arguments.sRightPrefix##q.sColumnName#)" )>
		<cfset sAdd= this.sTab & "AND" & this.sTab>
	</cfloop>
	
	<cfreturn>
</cffunction>



<cffunction name="appendQueryParam" access="package" output="false" returnType="string">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sField" type="string" required="true">
	<cfargument name="bNull" type="boolean" default="false">
	
	<cfset var q= this.getColumnMetadata( arguments.qMetadata, arguments.sField )>
	<cfset var out= "">
	
	<cfloop query="q">
		<cfset out= '<cfqueryparam value="##arguments.#q.fieldName###" cfSqlType="#q.cfSqlType#"'>
		
		<cfif q.nColumnLength GT 0 AND ( NOT arguments.bNull OR q.maxLength GTE 4 )>
			<cfset out &= ' maxLength="#q.maxLength#"'>
		</cfif>
		<cfif len( q.scale ) AND listFindNoCase( "decimal,double,float,money,smallmoney", q.sqlType )>
			<cfset out &= ' scale="#q.scale#"'>
		</cfif>
		<!--- <cfif len( q.scale ) AND listFindNoCase( "decimal,double,float,money,smallmoney", q.sqlType )>
			<cfset out &= ' list="##listLen( ##arguments.#q.fieldName###, "," )##" separator=","'>
		</cfif> --->
		<cfif arguments.bNull>
			<cfset out &= ' null="##( arguments.#q.fieldName# IS ''null'' )##"'>
		</cfif>
		<cfset out &= '>'>
	</cfloop>
	
	<cfreturn out>
</cffunction>



<!-----------------------------------------------------------------------------------------------------------
-- METADATA METHODS
------------------------------------------------------------------------------------------------------------>


<cffunction name="addDefinition" output="true">
	<cfargument name="sType" type="string" required="true">
	<cfargument name="stArgs" type="struct" required="true">
	<cfargument name="sSQL" type="string" required="true">
	
	<cfset var stDef= {}>
	<cfset var stParam= "">
	
	<cfquery name="qPK" dbType="query">
		SELECT		sColumnName
		FROM		stArgs.qFields
		WHERE		(bPrimaryKeyColumn = 1)
	</cfquery>
	
	<cfset stDef.sType= arguments.sType>
	<cfset stDef.stArgs= arguments.stArgs>
	<cfset stDef.stFields= this.getStructMetadata( stArgs.qFields )>
	<cfset stDef.sSQL= arguments.sSQL>
	<cfset stDef.created= now()>
	
	<cfif NOT structKeyExists( stDef.stArgs, "sDSN" )>
		<cfset stDef.stArgs.sDSN= this.dsn>
	</cfif>
	<cfif NOT structKeyExists( stDef.stArgs, "sQueryName" )>
		<cfset stDef.stArgs.sQueryName= "q" & replace( arguments.stArgs.sTableName, "_", "", "all" )>
	</cfif>
	<cfif NOT structKeyExists( stDef.stArgs, "lPrimaryKeys" )>
		<cfset stDef.stArgs.lPrimaryKeys= valueList( qPK.sColumnName )>
	</cfif>
	
	<cfset this.stDefinitions[ arguments.stArgs.sCrudName ]= stDef>
	
	<cfreturn>
</cffunction>


<cffunction name="getStructMetadata" output="false" returnType="struct">
	<cfargument name="qMetadata" type="query" required="true">
	
	<cfset var stMetadata= {}>
	<cfset var stParam= "">
	<cfloop query="qMetadata">
		<cfset stParam= {}>
		<!--- <cfset stParam.type= "in"> --->
		<!--- <cfset stParam.varName= "@" & qMetadata.sColumnName> --->
		<cfset stParam.fieldName= this.camelCase( qMetadata.fieldName )>
		<cfset stParam.sqlType= qMetadata.sTypeName>
		<cfset stParam.cfType= this.getCFType( qMetadata.sTypeName )>
		<cfset stParam.cfSQLType= lCase( this.getCFSQLType( qMetadata.sTypeName ) )>
		<!--- Only some default values will work on the CF side --->
		<cfset stParam.default= this.getCFDefaultValue( qMetadata.sDefaultValue )>
		<cfset stParam.index= qMetadata.nColumnID>
		<cfset stParam.scale= qMetadata.nColumnScale>
		<cfset stParam.precision= qMetadata.nColumnPrecision>
		<cfset stParam.maxLength= "">
		<cfset stParam.nullable= yesNoFormat( qMetadata.isNullable )>
		<cfset stParam.searchable= yesNoFormat( qMetadata.isSearchable )>
		<cfset stParam.attribs= "">
		<cfif len( qMetadata.sDefaultValue )>
			<cfset stParam.nullable= true>
		</cfif>
		<!--- <cfif qMetadata.isNullable>
			<cfset stParam.attribs= listAppend( stParam.attribs, "nullable" )>
		</cfif> --->
		<cfif qMetadata.isComputed IS 1>
			<cfset stParam.attribs= listAppend( stParam.attribs, "computed" )>
		</cfif>
		<cfif qMetadata.isIdentity IS 1>
			<cfset stParam.attribs= listAppend( stParam.attribs, "identity" )>
		</cfif>
		<cfif qMetadata.bPrimaryKeyColumn IS 1>
			<cfset stParam.attribs= listAppend( stParam.attribs, "primarykey" )>
		</cfif>
		<cfif listFindNoCase( "char,nchar,varchar,nvarchar", qMetadata.sTypeName )>
			<cfset stParam.maxLength= qMetadata.nColumnPrecision>
		</cfif>
		<cfset stMetadata[ qMetadata.sColumnName ]= stParam>
	</cfloop>

	<cfreturn stMetadata>
</cffunction>


<cffunction name="getBlankColumnMetadata" access="package" output="false" returnType="query">
	<cfreturn queryNew( "sColumnName,nColumnID,bPrimaryKeyColumn,nTypeGroup,nColumnLength,nColumnPrecision,nColumnScale,isNullable,isIdentity,sTypeName,sDefaultValue" )>
</cffunction>


<cffunction name="addColumnMetadataRow" access="package" output="false" returnType="query">
	<cfargument name="qMetadata" type="query" default="#this.getBlankColumnMetadata()#">
	
	<cfset var key= "">
	
	<cfset queryAddRow( arguments.qMetadata, 1 )>
	
	<cfif structKeyExists( arguments, "sTypeName" )>
		<cfswitch expression="#arguments.sTypeName#">
			<cfcase value="int">
				<cfset arguments.nTypeGroup= 0>
				<cfset arguments.nColumnLength= 4>
				<cfset arguments.nColumnPrecision= 10>
				<cfset arguments.nColumnScale= 0>
			</cfcase>
		</cfswitch>
		<cfif NOT structKeyExists( arguments, "isSearchable" )>
			<cfset arguments.isSearchable= this.isSearchableType( arguments.sTypeName )>
		</cfif>
	</cfif>
	
	<cfloop index="key" list="#arguments.qMetadata.columnList#">
		<cfif structKeyExists( arguments, key )>
			<cfset arguments.qMetadata.key[ arguments.qMetadata.recordCount ]= arguments[ key ]>
		<cfelse>
			<cfset arguments.qMetadata.key[ arguments.qMetadata.recordCount ]= "">
		</cfif>
	</cfloop>
	
	<cfset arguments.qMetadata.nColumnID[ arguments.qMetadata.recordCount ]= arguments.qMetadata.recordCount>
	
	<cfreturn arguments.qMetadata>
</cffunction>


<cffunction name="getTableMetadata" access="package" output="false" returnType="query">
	<cfargument name="sTableName" type="string" required="true">
	
		
	<cfquery name="qMetadata" dataSource="#this.dsn#">
		<cfif len( this.db )>
			USE #this.db#;
		</cfif>
		SELECT		nColumnID
				,	sColumnName
				,	bPrimaryKeyColumn
				,	nTypeGroup
				,	nColumnLength
				,	nColumnPrecision
				,	nColumnScale
				,	isNullable
				,	isComputed
				,	isIdentity
				,	isSearchable
				,	sTypeName
				,	sDefaultValue
				<!--- extra crap --->
				<!--- ,	'in' AS [type] --->
				<!--- ,	'@' + sColumnName AS [varName] --->
				,	sColumnName AS [sColumnNameSafe]
				,	sColumnName AS [fieldName]
				,	sTypeName AS [sqlType]
				,	sTypeName AS [cfType]
				,	sTypeName AS [cfSQLType]
				,	'' AS [default]
				,	nColumnID AS [index]
				,	nColumnScale AS [scale]
				,	0 AS [maxLength]
				,	isNullable AS [nullable]
				,	isSearchable AS [searchable]
				,	'' AS [attribs]
		FROM		dbo.udf_getTableColumnInfo2( '#arguments.sTableName#' )
		ORDER BY	1;
	</cfquery>
	
	<cfloop query="qMetadata">
		<cfset qMetadata.sColumnNameSafe[ currentRow ]= this.getSqlSafeName( qMetadata.sColumnName )>
		<cfset qMetadata.fieldName[ currentRow ]= this.camelCase( qMetadata.fieldName )>
		<cfset qMetadata.cfType[ currentRow ]= this.getCFType( qMetadata.cfType )>
		<cfset qMetadata.cfSQLType[ currentRow ]= lCase( this.getCFSQLType( qMetadata.cfSQLType ) )>
		<cfset qMetadata.nullable[ currentRow ]= yesNoFormat( qMetadata.isNullable )>
		<cfset qMetadata.searchable[ currentRow ]= yesNoFormat( qMetadata.isSearchable )>
		<cfif len( qMetadata.sDefaultValue )>
			<cfset qMetadata.nullable[ currentRow ]= true>
			<cfset qMetadata.isNullable[ currentRow ]= true>
		</cfif>
		<!--- <cfif qMetadata.isNullable>
			<cfset qMetadata.attribs[ currentRow ]= listAppend( qMetadata.attribs, "nullable" )>
		</cfif> --->
		<cfif qMetadata.isComputed IS 1>
			<cfset qMetadata.attribs[ currentRow ]= listAppend( qMetadata.attribs, "computed" )>
		</cfif>
		<cfif qMetadata.isIdentity IS 1>
			<cfset qMetadata.attribs[ currentRow ]= listAppend( qMetadata.attribs, "identity" )>
		</cfif>
		<cfif qMetadata.bPrimaryKeyColumn IS 1>
			<cfset qMetadata.attribs[ currentRow ]= listAppend( qMetadata.attribs, "primarykey" )>
		</cfif>
		<cfif listFindNoCase( "char,nchar,varchar,nvarchar", qMetadata.sTypeName )>
			<cfset qMetadata.maxLength[ currentRow ]= qMetadata.nColumnLength>
		</cfif>
	</cfloop>
	
	<cfreturn qMetadata>
</cffunction>


<cffunction name="getColumnMetadata" access="package" output="false" returnType="query">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sColumns" type="string" required="true">
	
	<cfquery name="qColumnMetadata" dbType="query">
		SELECT		*
		FROM		qMetadata
		WHERE		(0=0)
		<cfif len( arguments.sColumns )>
			AND		(sColumnName IN (<cfqueryparam value="#arguments.sColumns#" cfsqltype="varchar" list="true" separator=",">))
		<cfelse>
			AND		(0=1)
		</cfif>			
	</cfquery>
	
	<cfreturn qColumnMetadata>
</cffunction>


<cffunction name="filterColumnMetadata" access="package" output="false" returnType="query">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sFilter" type="string" default="*">
	
	<cfset var bKeyFilter= false>
	<cfset var bNullFilter= "">
	<cfset var bLikeableFilter= false>
	<cfset var bComputedFilter= false>
	<cfset var bCompareFilter= false>
	<cfset var sField= "">
	<cfset var sIncludeFields= "">
	<cfset var sExcludeFields= "">
	
	<cfloop index="sField" list="#arguments.sFilter#" delimiters=",">
		<cfif sField IS "!PK">
			<cfset bKeyFilter= true>
		<cfelseif sField IS "!MUTABLE" OR sField IS "+">
			<cfset bComputedFilter= true>
		<cfelseif sField IS "!COMPARABLE">
			<cfset bCompareFilter= true>
		<cfelseif sField IS "!NULL">
			<cfset bNullFilter= 1>
		<cfelseif sField IS "!NOTNULL">
			<cfset bNullFilter= 0>
		<cfelseif sField IS "!LIKEABLE">
			<cfset bLikeableFilter= true>
		<cfelseif NOT sField IS "*">
			<cfif left( sField, 1 ) IS "-">
				<cfset sExcludeFields= listAppend( sExcludeFields, right( sField, len( sField ) - 1 ), "," )>
			<cfelse>
				<cfset sIncludeFields= listAppend( sIncludeFields, sField, "," )>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfquery name="qFilteredColumnMetadata" dbType="query">
		SELECT		*
		FROM		qMetadata
		WHERE		(0 = 0)
		<cfif bKeyFilter>
			AND		(bPrimaryKeyColumn = 1)
		<cfelseif bComputedFilter>
			AND		(isComputed = 0)
			AND		(isIdentity = 0)
		</cfif>
		<cfif bCompareFilter>
			AND		(sTypeName NOT IN ('text','ntext','image','binary','varbinary','xml'))
		</cfif>
		<cfif bLikeableFilter>
			AND		(sTypeName IN ('char','varchar','text','nchar','nvarchar','ntext'))
		</cfif>
		<cfif len( bNullFilter )>
			AND		(isNullable = #bNullFilter#)
		</cfif>
		<cfif arguments.sFilter IS "-">
			AND		(0 = 1)
		<cfelseif len( sIncludeFields )>
			AND		(sColumnName IN (<cfqueryparam value="#sIncludeFields#" cfsqltype="varchar" list="true" separator=",">))
		<cfelseif len( sExcludeFields )>
			AND		(sColumnName NOT IN (<cfqueryparam value="#sExcludeFields#" cfsqltype="varchar" list="true" separator=",">))
		</cfif>
	</cfquery>
	
	<cfreturn qFilteredColumnMetadata>
</cffunction>


<cffunction name="filterColumnList" access="package" output="false" returnType="string">
	<cfargument name="qMetadata" type="query" required="true">
	<cfargument name="sFilter" type="string" default="*">
	
	<cfset var bPKFilter= false>
	<cfset var bNullFilter= "">
	<cfset var bLikeableFilter= false>
	<cfset var bComputedFilter= false>
	<cfset var bCompareFilter= false>
	<cfset var sField= "">
	<cfset var sIncludeFields= "">
	<cfset var sExcludeFields= "">
	
	<!--- don't select any fields --->
	<cfif NOT len( sFilter ) OR sFilter IS "-">
		<cfset arguments.sFilter= "-">
	<cfelse>
		<cfloop index="sField" list="#arguments.sFilter#" delimiters=",">
			<cfif sField IS "!PK">
				<!--- only select primary key columns --->
				<cfset bPKFilter= true>
			<cfelseif sField IS "!MUTABLE" OR sField IS "+">
				<!--- exclude computed and identity fields --->
				<cfset bComputedFilter= true>
			<cfelseif sField IS "!COMPARABLE">
				<cfset bCompareFilter= true>
			<cfelseif sField IS "!NULL">
				<cfset bNullFilter= 1>
			<cfelseif sField IS "!NOTNULL">
				<cfset bNullFilter= 0>
			<cfelseif sField IS "!LIKEABLE">
				<cfset bLikeableFilter= true>
			<cfelseif NOT sField IS "*">
				<cfif left( sField, 1 ) IS "-">
					<cfset sExcludeFields= listAppend( sExcludeFields, right( sField, len( sField ) - 1 ), "," )>
				<cfelse>
					<cfset sIncludeFields= listAppend( sIncludeFields, sField, "," )>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfquery name="qFilteredList" dbType="query">
		SELECT		sColumnName
		FROM		qMetadata
		WHERE		(0 = 0)
		<cfif bPKFilter>
			AND		(bPrimaryKeyColumn = 1)
		<cfelseif bComputedFilter>
			AND		(isComputed = 0)
			AND		(isIdentity = 0)
		</cfif>
		<cfif bCompareFilter>
			AND		(sTypeName NOT IN ('TEXT','NTEXT','IMAGE','BINARY','VARBINARY','XML'))
		</cfif>
		<cfif bLikeableFilter>
			AND		(sTypeName IN ('CHAR','VARCHAR','TEXT','NCHAR','NVARCHAR','NTEXT'))
		</cfif>
		<cfif len( bNullFilter )>
			AND		(isNullable = #bNullFilter#)
		</cfif>
		<cfif sFilter IS "-">
			AND		(0 = 1)
		<cfelseif len( sIncludeFields )>
			AND		(sColumnName IN (<cfqueryparam value="#sIncludeFields#" cfsqltype="varchar" list="true" separator=",">))
		<cfelseif len( sExcludeFields )>
			AND		(sColumnName NOT IN (<cfqueryparam value="#sExcludeFields#" cfsqltype="varchar" list="true" separator=",">))
		</cfif>
	</cfquery>
	
	<cfreturn udf.listSortByListNoCase( valueList( qFilteredList.sColumnName ), sIncludeFields )>
</cffunction>

	
<!-----------------------------------------------------------------------------------------------------------
-- METHODS TO CONTROL AND MANAGE THE BUFFER
------------------------------------------------------------------------------------------------------------>


<cffunction name="indent" access="package" output="false" hint="Increase the indentation by 1">
	<cfargument name="indent" type="numeric" default="1">
	<cfset this.nIndent= this.nIndent + arguments.indent>
	<cfreturn>
</cffunction>


<cffunction name="unindent" access="package" output="false" hint="Decrease the indentation by 1">
	<cfargument name="indent" type="numeric" default="1">
	<cfset this.nIndent= max( 0, this.nIndent - arguments.indent )>
	<cfreturn>
</cffunction>


<cffunction name="addIndent" access="package" output="false" hint="Change the level of indentation">
	<cfargument name="indent" type="numeric" required="true">
	<cfset this.nIndent= max( 0, this.nIndent + arguments.indent )>
	<cfreturn>
</cffunction>


<cffunction name="resetIndent" access="package" output="false" hint="Reset the level of indentation to zero">
	<cfset this.nIndent= 0>
	<cfreturn>
</cffunction>


<cffunction name="clearBuffers" output="false">
	
	<!--- clear the buffers --->
	<cfset this.lBufferOrder= "">
	<cfset this.stBuffer= {}>
	<cfset this.stBufferType= {}>
	<cfset this.stDefinitions= {}>
	
	<!--- add the standard 'header' buffers --->
	<cfset this.appendHeader()>
	
	<cfreturn>
</cffunction>


<cffunction name="addBuffer" access="package" output="false">
	<cfargument name="sBufferKey" type="string" required="true">
	<cfargument name="sBufferType" type="string" default="cfm">
	<cfargument name="bAddFinish" type="boolean" default="false">
	
	<!--- add a bunch of line breaks to the end of the file --->
	<cfif arguments.bAddFinish AND len( this.sCurrentBuffer )>
		<cfset this.appendBlank()>
		<cfset this.appendDivide()>
		<cfset this.appendBlank()>
		<cfset this.appendBlank()>
	</cfif>
	
	<!--- check that the key doesn't exist already --->
	<cfif structKeyExists( this.stBuffer, arguments.sBufferKey )>
		<cfthrow
			type="Custom.CFC.BufferAlreadyExists"
			message="Buffer referenced by key ""#arguments.sBufferKey#"" already exists."
		>
	</cfif>
	
	<!--- add an empty buffer --->
	<cfset this.stBuffer[ arguments.sBufferKey ]= "">
	
	<!--- save the buffer type --->
	<cfset this.stBufferType[ arguments.sBufferKey ]= arguments.sBufferType>
	
	<!--- save the buffer order --->
	<cfset this.lBufferOrder= listAppend( this.lBufferOrder, arguments.sBufferKey )>
	
	<!--- mark the buffer as 'current' --->
	<cfset this.sCurrentBuffer= arguments.sBufferKey>
	
	<cfreturn>
</cffunction>


<cffunction name="readBuffer" output="false" returnType="string">
	<cfargument name="sBufferKey" type="string" default="*">
	<cfargument name="sBufferType" type="string" default="*"><!--- *, sql or cfm --->
	
	<cfset var sOutput= "">
	<cfset var sItem= "">
	
	<cfif arguments.sBufferKey IS "*">
		<cfset arguments.sBufferKey= this.lBufferOrder>
	<cfelse>
		<cfset arguments.sBufferType= "*">
	</cfif>
	
	<!--- read only the buffer specified "*", "sql" or "cfm" --->
	<cfloop index="sItem" list="#arguments.sBufferKey#">
		<cfif arguments.sBufferType IS "*" OR this.stBufferType[ sItem ] IS arguments.sBufferType>
			<cfset sOutput= sOutput & this.stBuffer[ sItem ] & this.sNewLine>
		</cfif>
	</cfloop>
	
	<cfreturn trim( sOutput )>
</cffunction>


<cffunction name="writeIfDifferent" output="false">
	<cfargument name="sFileName" type="string" required="true">
	<cfargument name="sContent" type="string" required="true">
	
	<cfset var bWrite= true>
	
	<cfif fileExists( sFileName )>
		<cfset local.sOldContent= fileRead( local.sFileName )>
		<cfif compare( arguments.sContent, local.sOldContent ) IS 0>
			<cfset bWrite= false>
		</cfif>
	</cfif>
	
	<cfif bWrite>
		<cfset fileWrite( arguments.sFileName, arguments.sContent )>
	</cfif>
	
	<cfreturn>		
</cffunction>


<cffunction name="writeBuffer" output="false">
	<cfargument name="sFileName" type="string" required="true">
	<cfargument name="sBufferKey" type="string" default="*">
	<cfargument name="sBufferType" type="string" default="cfm"><!--- *, sql or cfm --->
	<cfargument name="bGroup" type="boolean" default="false">
	<cfset var sItem= "">
	
	<cfset this.writeIfDifferent( arguments.sFileName, this.readBuffer( arguments.sBufferKey, arguments.sBufferType ) )>
	
	<cfreturn>
</cffunction>



<cffunction name="outputBuffer" output="true">
	<cfoutput>#this.readBuffer( "*", "*" )#</cfoutput>
	<cfreturn>
</cffunction>




<!-----------------------------------------------------------------------------------------------------------
-- MISC
------------------------------------------------------------------------------------------------------------>



<cffunction name="getCFDefaultValue" output="false" returnType="string">
	<cfargument name="sValue" type="string" required="true">
	
	<cfreturn "">
	
	<cfif left( arguments.sValue, 1 ) IS "'" AND right( arguments.sValue, 1 ) IS "'">
		<cfset arguments.sValue= mid( arguments.sValue, 2, len( arguments.sValue ) - 2 )>
	</cfif>
	
	<cfif arguments.sValue IS "GETDATE()">
		<cfreturn "##now()##">
	<cfelseif reFind( "(\[\]\(\)\@\+\*%/)", arguments.sValue )>
		<cfreturn "">
	<cfelseif isNumeric( arguments.sValue )>
		<cfreturn arguments.sValue>
	<cfelseif isBoolean( arguments.sValue )>
		<cfreturn arguments.sValue>
	</cfif>
	
	<cfreturn "">
</cffunction>


<cffunction name="getCFType" output="false" returnType="string">
	<cfargument name="sType" type="string" required="true">
	
	<cfswitch expression="#arguments.sType#">
		<cfcase value="CHAR,VARCHAR,TEXT,NCHAR,NVARCHAR,XML,NTEXT,UNIQUEIDENTIFIER">
			<cfreturn "string">
		</cfcase>
		<cfcase value="BIT">
			<cfreturn "boolean">
		</cfcase>
		<cfcase value="BIGINT,INT,SMALLINT,TINYINT,DECIMAL,NUMERIC,MONEY,SMALLMONEY,FLOAT,REAL">
			<cfreturn "numeric">
		</cfcase>
		<cfcase value="DATETIME,SMALLDATETIME">
			<cfreturn "date">
		</cfcase>
		<cfcase value="BINARY,VARBINARY,IMAGE">
			<cfreturn "binary">
		</cfcase>
	</cfswitch>
	
	<cfreturn "any">
</cffunction>


<cffunction name="getCFSQLType" output="false" returnType="string">
	<cfargument name="sType" type="string" required="true">

	<cfswitch expression="#arguments.sType#">
		<cfcase value="VARCHAR,NVARCHAR,XML">
			<cfreturn "varchar">
		</cfcase>
		<cfcase value="CHAR,NCHAR">
			<cfreturn "char">
		</cfcase>
		<cfcase value="TEXT,NTEXT">
			<cfreturn "longVarchar">
		</cfcase>
		<cfcase value="INT">
			<cfreturn "integer">
		</cfcase>
		<cfcase value="BIGINT">
			<cfreturn "bigInt">
		</cfcase>
		<cfcase value="TINYINT">
			<cfreturn "tinyInt">
		</cfcase>
		<cfcase value="SMALLINT">
			<cfreturn "smallInt">
		</cfcase>
		<cfcase value="BIT">
			<cfreturn "bit">
		</cfcase>
		<cfcase value="MONEY,SMALLMONEY">
			<cfreturn "money">
			<!--- <cfreturn "money4"> --->
		</cfcase>
		<cfcase value="DATETIME,SMALLDATETIME,TIMESTAMP">
			<cfreturn "timeStamp">
		</cfcase>
		<cfcase value="DATE">
			<cfreturn "date">
		</cfcase>
		<cfcase value="TIME">
			<cfreturn "time">
		</cfcase>
		<cfcase value="DOUBLE">
			<cfreturn "double">
		</cfcase>
		<cfcase value="REAL">
			<cfreturn "real">
		</cfcase>
		<cfcase value="FLOAT">
			<cfreturn "float">
		</cfcase>
		<cfcase value="DECIMAL">
			<cfreturn "decimal">
		</cfcase>
		<cfcase value="NUMERIC">
			<cfreturn "numeric">
		</cfcase>
		<cfcase value="BINARY">
			<cfreturn "blob">
		</cfcase>
		<cfcase value="VARBINARY">
			<cfreturn "varBinary" />
		</cfcase>
		<cfcase value="IMAGE">
			<cfreturn "longVarBinary" />
		</cfcase>
		<cfcase value="UNIQUEIDENTIFIER">
			<cfreturn "char" />
		</cfcase>
		<!--- <cfdefaultcase>
			<cfreturn uCase( "#arguments.sType#" )>
		</cfdefaultcase> --->
	</cfswitch>
	
	<cfreturn "">
</cffunction>


<cffunction name="isSearchableType" output="false" returnType="string">
	<cfargument name="sType" type="string" required="true">
	
	<cfif listFindNoCase( "TEXT,NTEXT,TIMESTAMP,BINARY,VARBINARY,IMAGE", sType )>
		<cfreturn false>
	</cfif>
	
	<cfreturn true>
</cffunction>


<cffunction name="getSqlSafeName" output="false" returntype="string">
	<cfargument name="sInput" type="string" required="true">
	
	<cfif listFindNoCase( "ADD,EXCEPT,PERCENT,ALL,EXEC,PLAN,ALTER,EXECUTE,PRECISION,AND,EXISTS,PRIMARY,ANY,EXIT,PRINT,AS,"
				& "FETCH,PROC,ASC,FILE,PROCEDURE,AUTHORIZATION,FILLFACTOR,PUBLIC,BACKUP,FOR,RAISERROR,BEGIN,FOREIGN,READ,"
				& "BETWEEN,FREETEXT,READTEXT,BREAK,FREETEXTTABLE,RECONFIGURE,BROWSE,FROM,REFERENCES,BULK,FULL,REPLICATION,"
				& "BY,FUNCTION,RESTORE,CASCADE,GOTO,RESTRICT,CASE,GRANT,RETURN,CHECK,GROUP,REVOKE,CHECKPOINT,HAVING,RIGHT,"
				& "CLOSE,HOLDLOCK,ROLLBACK,CLUSTERED,IDENTITY,ROWCOUNT,COALESCE,IDENTITY_INSERT,ROWGUIDCOL,COLLATE,IDENTITYCOL,"
				& "RULE,COLUMN,IF,SAVE,COMMIT,IN,SCHEMA,COMPUTE,INDEX,SELECT,CONSTRAINT,INNER,SESSION_USER,CONTAINS,INSERT,"
				& "SET,CONTAINSTABLE,INTERSECT,SETUSER,CONTINUE,INTO,SHUTDOWN,CONVERT,IS,SOME,CREATE,JOIN,STATISTICS,CROSS,"
				& "KEY,SYSTEM_USER,CURRENT,KILL,TABLE,CURRENT_DATE,LEFT,TEXTSIZE,CURRENT_TIME,LIKE,THEN,CURRENT_TIMESTAMP,"
				& "LINENO,TO,CURRENT_USER,LOAD,TOP,CURSOR,NATIONAL,TRAN,DATABASE,NOCHECK,TRANSACTION,DBCC,NONCLUSTERED,TRIGGER,"
				& "DEALLOCATE,NOT,TRUNCATE,DECLARE,NULL,TSEQUAL,DEFAULT,NULLIF,UNION,DELETE,OF,UNIQUE,DENY,OFF,UPDATE,DESC,"
				& "OFFSETS,UPDATETEXT,DISK,ON,USE,DISTINCT,OPEN,USER,DISTRIBUTED,OPENDATASOURCE,VALUES,DOUBLE,OPENQUERY,"
				& "VARYING,DROP,OPENROWSET,VIEW,DUMMY,OPENXML,WAITFOR,DUMP,OPTION,WHEN,ELSE,OR,WHERE,END,ORDER,WHILE,ERRLVL,"
				& "OUTER,WITH,ESCAPE,OVER,WRITETEXT", sInput )>
		<cfreturn "[" & sInput & "]">	
	</cfif>
	
	<cfreturn sInput>
</cffunction>


<cffunction name="camelCase" output="false" returntype="string">
	<cfargument name="sInput" type="string" required="true">
	<cfargument name="sDelim" type="string" default="_">
	
	<cfset var sOutput= "">
	<cfset var word= "">
	<cfset var i= 1>
	<cfset var strlen= listLen( sInput, sDelim )>
	
	<cfif NOT len( sInput )>
		<cfreturn "">
	</cfif>
	
	<cfscript>
		for( i=1; i LTE strlen; i=i+1 ) {
			word= listGetAt( sInput, i, sDelim );
			sOutput &= uCase( left( word, 1 ) );
			if( len( word ) GT 1 ) {
				sOutput &= right( word, len( word ) - 1 );
			}
			if( i LT strlen ) {
				sOutput= sOutput;
			}
		}
	</cfscript>
	
	<!--- camel-case the first letter --->
	<cfset sOutput= lCase( left( sOutput, 1 ) ) & replaceList( right( sOutput, len( sOutput ) - 1 ), "Id,Pk,Fk,Ukey,Rkey", "ID,PK,FK,UKey,RKey" )>
	
	<cfreturn sOutput>
</cffunction>


<cffunction name="componentFromDir2" output="false">
	<cfargument name="directory" type="string" required="true">
	<cfargument name="filename" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="display" type="string" default="#arguments.name#">
	<cfargument name="extends" type="string" default="">
	<cfargument name="hint" type="string" default="">
	<cfargument name="output" type="string" default="false">
	<cfargument name="fileFilter" type="string" default="*.cfm">
	<cfargument name="inlineFilter" type="string" default="*.cfm">
	<cfargument name="fileAttributes" type="string" default="normal">
	<cfargument name="fileMode" type="string" default="660">
	<cfargument name="stripComments" type="boolean" default="true">
	<cfargument name="silent" type="boolean" default="true">
	<cfargument name="separator" type="string" default="/">
	
	<cfset var newline= chr(13)&chr(10)>
	<cfset var tab= chr(9)>
	<cfset var content= "">
	<cfset var functionContent= "">
	<cfset var functionName= "">
	<cfset var originalName= "">
	<cfset var functions= structNew()>
	<cfset var objNamePattern= createObject( "java", "java.util.regex.Pattern" ).Compile( '(?i)(?<=<cffunction name=")[^"]+(?=")' )>
	<cfset var objNameMatcher= 0>
	
	<cfset content= '<cfcomponent'>
	<cfif len( arguments.extends )>
		<cfset content &= ' extends="#arguments.extends#"'>
	</cfif>
	<cfif len( arguments.output )>
		<cfset content &= ' output="#arguments.output#"'>
	</cfif>
	<cfif len( arguments.display )>
		<cfset content &= '#newline##tab#displayName="#arguments.display#"'>
	</cfif>
	<cfif len( arguments.hint )>
		<cfset content &= '#newline##tab#hint="#arguments.hint#"'>
	</cfif>
	<cfset content &= '>#newline#'>
	
	<cfdirectory
		action="list"
		directory="#arguments.directory#"
		name="qFiles"
		filter="#arguments.fileFilter#"
		recurse="true"
		sort="name DESC"
	>
	
	<cfloop query="qFiles">
		<cffile action="read"
			file="#arguments.directory##arguments.separator##qFiles.name#"
			variable="functionContent"
		>
		<cfset functionContent= trim( functionContent )>
		<cfif arguments.stripComments>
			<!--- remove comments --->
			<cfset functionContent= replaceList( functionContent, "<!---,--->", "`,`" )>
			<cfset functionContent= reReplaceNoCase( functionContent, "`([^`]+)`", "", "all" ) & newline>
		</cfif>
		<!--- indent --->
		<!--- <cfset functionContent= tab & replace( trim( functionContent ), chr(13), chr(13) & tab, "all" )> --->
		
		<cfset objNameMatcher= objNamePattern.Matcher( functionContent )>
		<cfif objNameMatcher.find()>
			<cfset functionName= objNameMatcher.Group()>
			<cfset originalName= functionName>
			<cfif left( functionName, 2 ) IS "db">
				<cfset functionName= replace( functionName, "db", "" )>
			</cfif>
			
			<cfif len( arguments.inlineFilter ) AND reFindNoCase( replaceList( arguments.inlineFilter, ".,*,?", "\.,.+,." ), qFiles.name )>
				<cfset functionContent= '<cfinclude template="#qFiles.name#">' & newline>
				<cfif left( originalName, 2 ) IS "db">
					<cfset functionContent &= '<cfset this.#functionName# = variables.#originalName#>' & newline>
					<cfset functionContent &= '<cfset structDelete( variables, "#originalName#" )>' & newline>
				</cfif>
			</cfif>
			
			<cfset functions[ functionName ]= functionContent>
		</cfif>
	</cfloop>
	
	<cfif arguments.silent>
		<cfset content &= newline & '<cfsilent>' & newline>
	</cfif>
	
	<cfloop list="#listSort( structKeyList( functions ), "text" )#" index="functionName">
		<cfset content &= newline & '<!--- #functionName# --->'>
		<cfset content &= newline & functions[ functionName ]>
	</cfloop>
	
	<cfif arguments.silent>
		<cfset content &= newline & '</cfsilent>'>
	</cfif>
	<cfset content &= newline & '</cfcomponent>'>
	
	<cffile action="write"
		file="#arguments.filename#"
		output="#content#"
		attributes="#arguments.fileAttributes#"
		mode="#arguments.fileMode#"
		addNewLine="false"
	>
	
	<cfreturn>
</cffunction>
		
		
</cfcomponent>