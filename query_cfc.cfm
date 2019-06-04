
<!--- stArgs can contain: output, returnType, access, roles, display --->
<cffunction name="genCFC" output="true" returnType="string">

<cfargument name="stDef" type="struct" required="true">

<cfset var sItem = "">
<cfset var nSetSelect = "">
<cfset var sLComment = "<!" & "---">
<cfset var sRComment = "---" & ">">
<cfset var sName = "">
<cfset var sQuery = "">

<!--- overwrite any of the arguments with whatever is passed --->
<cfset structAppend( stDef.stArgs, arguments, true )>
<!--- <cfset request.log( stDef )> --->

<cfset sName = this.camelCase( "db_" & stDef.stArgs.sCrudName )>
<cfset sQuery = replace( sName, "db", "q", "one" )>

<!--- New buffer for crud --->
<cfset this.addBuffer( "query_#this.owner#.#stDef.stArgs.sCrudName#", "cfm", true )>

<cfset this.append( '<cffunction name="#stDef.stArgs.sUdfName#" output="false"' )>
<cfloop index="sItem" list="access,roles,display">
	<cfif structKeyExists( stDef.stArgs, "sUdf" & sItem )>
		<cfset this.appendOn( ' #sItem#="#stDef.stArgs[ 'sUdf' & sItem ]#"' )>
	</cfif>
</cfloop>
<cfif stDef.sType IS "record">
	<cfset this.appendOn( ' returnType="struct">' )>
<cfelseif listFindNoCase( "select,selectSet,paginate", stDef.sType )>
	<cfset this.appendOn( ' returnType="query">' )>
<cfelseif stDef.sType IS "exists">
	<cfset this.appendOn( ' returnType="boolean">' )>
<cfelseif listFindNoCase( "insert,merge,upsert,save", stDef.sType ) AND stDef.stArgs.bIdentityField>
	<cfset this.appendOn( ' returnType="numeric">' )>
<cfelseif listFindNoCase( "count,update,delete,remove", stDef.sType )>
	 <cfset this.appendOn( ' returnType="numeric">' )>
<cfelse>
	<cfset this.appendOn( '>' )>
</cfif>

<!--- <cfset this.indent()> --->
<cfset this.appendBlank()>

<cfif stDef.sType IS "paginate">
	<cfset this.appendLine( '<cfargument name="page" type="numeric" default="1">' )>
	<cfset this.appendLine( '<cfargument name="pageSize" type="numeric" default="100">' )>
</cfif>
<!--- add parameters for the input fields --->
<cfloop index="sItem" list="#stDef.stArgs.lArgFields#">
	<cfset this.appendLine( '<cfargument name="#stDef.stFields[ sItem ].fieldName#"' )>
	<!--- hack in for <cfargument> which wont allow a null "" numeric value to be passed in --->
	<cfif listFindNoCase( stDef.stArgs.lArgsOptional, sItem )
		OR ( NOT len( stDef.stFields[ sItem ].default ) AND stDef.stFields[ sItem ].nullable )
		OR listFindNoCase( "merge,upsert,save", stDef.sType )
		OR listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" )>
		<cfset this.appendOn( ' type="string"' )>
	<cfelse>
		<cfset this.appendOn( ' type="#stDef.stFields[ sItem ].cfType#"' )>
	</cfif>
	<cfset request.log( "SAVE CRUD" )>
	<cfset request.log( stDef )>
	
	<!--- give a default value if possible --->
	<cfif listFindNoCase( "count,exists,remove,search,select,paginate", stDef.sType )>
		<cfset this.appendOn( ' default=""' )>
	<cfelseif listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" ) AND listFindNoCase( "update,save,merge,upsert", stDef.sType )>
		<cfset this.appendOn( ' default="0"' )>
	<cfelseif listFindNoCase( stDef.stArgs.lPrimaryKeys, sItem )>
		<cfset this.appendOn( ' required="true"' )>
	<cfelseif len( stDef.stFields[ sItem ].default ) OR stDef.stFields[ sItem ].nullable>
		<cfset this.appendOn( ' default="#stDef.stFields[ sItem ].default#"' )>
	<cfelseif listFindNoCase( "update,merge,upsert,save", stDef.sType )>
		<cfset this.appendOn( ' default=""' )>
	<cfelse>
		<cfset this.appendOn( ' required="true"' )>
	</cfif>
	<cfset this.appendOn( ' hint="' )>
	<cfif structKeyExists( stDef.stArgs, "lLikeFields" ) AND listFindNoCase( stDef.stArgs.lLikeFields, sItem )>
		<cfset this.appendOn( 'Like Matchable. ' )>
	</cfif>
	<cfif stDef.stFields[ sItem ].cfType IS NOT "string">
		<cfif listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) OR listFindNoCase( "merge,upsert,save", stDef.sType )>
			<cfset this.appendOn( 'Type is #uCase( stDef.stFields[ sItem ].cfType )#.' )>
		<cfelseif NOT len( stDef.stFields[ sItem ].default ) AND stDef.stFields[ sItem ].nullable>
			<cfset this.appendOn( 'Type is #uCase( stDef.stFields[ sItem ].cfType )#, but is nullable.' )>
		</cfif>
	</cfif>
	<cfset this.appendOn( '"' )>
	<cfset this.appendOn( '>' )>
</cfloop>
<!--- parameters for the different query types --->
<cfif structKeyExists( stDef.stArgs, "bRowLimit" ) AND stDef.stArgs.bRowLimit>
	<cfset this.appendLine( '<cfargument name="rows" type="numeric" default="-1">' )>
</cfif>
<!--- <cfif structKeyExists( stDef.stArgs, "bDebuggable" ) AND stDef.stArgs.bDebuggable>
	<cfset this.appendLine( '<cfargument name="debug" type="boolean" default="false">' )>
</cfif> --->
<!---<cfset this.appendBlank()>--->

<!--- comment to remind what fields are included in select sets --->
<cfif structKeyExists( stDef.stArgs, "sSetSelect" )>
	<cfset this.appendBlank()>
	<cfset this.appendLine( sLComment )>
	<cfloop index="nSetSelect" from="1" to="#stDef.stArgs.nSetSelectLength#">
		<cfset this.appendLine( 'Select Set ###nSetSelect# = #listGetAt( stDef.stArgs.lSetSelectFields, nSetSelect, "|" )#' )>
	</cfloop>
	<cfset this.appendLine( sRComment )>
</cfif>

<!--- SET VAR for ACF or "classic" scope mode in lucee --->
<!---<cfif structKeyExists( stDef.stArgs, "sSetSelect" )>
	<cfset this.appendLine( '<cfset var #sQuery###arguments.selectSet## = 0>' )>
<cfelse>
	<cfset this.appendLine( '<cfset var #sQuery# = 0>' )>
</cfif>--->
<!--- <cfif structKeyExists( stDef.stArgs, "bDebuggable" ) AND stDef.stArgs.bDebuggable>
	<cfset this.appendLine( '<cfset var sql = 0>' )>
</cfif> --->

<cfif listFindNoCase( "merge,upsert,save", stDef.sType )>
	<cfloop index="sItem" list="#stDef.stArgs.lArgFields#">
		<cfif listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" )>
			<cfset this.appendBlank()>
			<cfset this.append( "<cfif arguments.#stDef.stFields[ sItem ].fieldName# IS """" OR arguments.#stDef.stFields[ sItem ].fieldName# IS ""0""><cfset arguments.#stDef.stFields[ sItem ].fieldName# = ""null""></cfif>" )>
		</cfif>
	</cfloop>
</cfif>

<!--- build the crud tag --->
<cfset this.appendBlank()>
<cfset this.appendLine( '<cfquery' )>
<cfif structKeyExists( stDef.stArgs, "sSetSelect" )>
	<cfset this.appendOn( ' name="#sQuery###arguments.selectSet##"' )>
<cfelse>
	<cfset this.appendOn( ' name="#sQuery#"' )>
</cfif>
<cfif stDef.sType IS "record">
	<cfset this.appendOn( ' maxRows="1"' )>
<cfelseif structKeyExists( stDef.stArgs, "bRowLimit" ) AND stDef.stArgs.bRowLimit>
	<cfset this.appendOn( ' maxRows="##arguments.rows##"' )>
</cfif>
<cfif structKeyExists( stDef.stArgs, "bDebuggable" ) AND stDef.stArgs.bDebuggable>
	<cfset this.appendOn( ' debug="##this.debug##"' )>
	<!--- <cfset this.appendOn( ' result="sql"' )> --->
</cfif>
<cfif len( stDef.stArgs.sDSN )>
	<cfset this.appendOn( ' dataSource="#stDef.stArgs.sDSN#"' )>
</cfif>
<cfif structKeyExists( stDef.stArgs, "sTimeOut" ) AND len( stDef.stArgs.sTimeOut )>
	<cfset this.appendOn( ' timeOut="#stDef.stArgs.sTimeOut#"' )>
</cfif>
<cfset this.appendOn( '>' )>
<cfset this.indent()>

	<!--- append original crud t-sql to cfml code for easy reference --->
	<cfset this.appendLine( replace( stDef.sSql, this.sNewLine, this.sNewLine & repeatString( this.sTab, this.nIndent ), "all" ) )>

<cfset this.unindent()>
<cfset this.appendLine( '</cfquery>' )>
<cfset this.appendBlank()>

<cfif stDef.sType IS "record">
	<cfset this.appendLine( '<cfset var record = {' )>
	<cfset c = "">
	<cfloop index="sItem" list="#stDef.stArgs.lSelectFields#">
		<cfset this.appendLine( '#c##stDef.stFields[ sItem ].fieldName#= #sQuery#.#stDef.stFields[ sItem ].fieldName#' )>
		<cfset c = ",">
	</cfloop>
	<cfset this.appendLine( '}>' )>
	<cfset this.appendBlank()>
</cfif>

<!--- return relavant data --->
<cfif stDef.sType IS "record">
	<cfset this.appendLine( '<cfreturn record>' )>
<cfelseif listFindNoCase( "select,selectSet,paginate", stDef.sType )>
	<cfset this.appendLine( '<cfreturn #sQuery#>' )>
<cfelseif stDef.sType IS "count">
	<cfset this.appendLine( '<cfreturn val( #sQuery#.total )>' )>
<cfelseif stDef.sType IS "exists">
	<cfset this.appendLine( '<cfreturn ( #sQuery#.recordCount GT 0 )>' )>
<cfelseif listFindNoCase( "insert,merge,upsert,save", stDef.sType ) AND stDef.stArgs.bIdentityField>
	<cfset this.appendLine( '<cfreturn val( #sQuery#.pk_identity )>' )>
<cfelseif listFindNoCase( "update,delete,remove", stDef.sType )>
	<cfset this.appendLine( '<cfreturn val( #sQuery#.row_count )>' )>
<cfelse>
	<cfset this.appendLine( sLComment & ' no output ' & sRComment )>
	<cfset this.appendLine( '<cfreturn>' )>
</cfif>

<cfset this.appendBlank()>
<!--- <cfset this.unindent()> --->
<cfset this.appendLine( '</cffunction>' )>

<!--- add real function name to cfc --->
<!--- <cfset this.appendBlank()> --->
<!--- <cfset this.appendLine( '<cfset this.#right( stDef.stArgs.sUdfName, len( stDef.stArgs.sUdfName ) - 2 )# = variables.#stDef.stArgs.sUdfName#>' )> --->
<!--- <cfset this.appendLine( '<cfset structDelete( variables, "#stDef.stArgs.sUdfName#" )>' )> --->

<cfset this.appendBlank()>


<!--- create sample code comment --->
<cfif structKeyExists( stDef.stArgs, "bSampleCode" ) AND stDef.stArgs.bSampleCode>
	<cfset this.appendLine( sLComment )>
	<cfset this.appendLine( '<cfset foo= BOOT.crud( "#stDef.stArgs.sTableName#.#right( stDef.stArgs.sUdfName, len( stDef.stArgs.sUdfName ) - 2 )#" )(' )>
	<cfset this.indent()>
		<cfloop index="sItem" list="#stDef.stArgs.lArgFields#">
			<cfset this.appendLine( ',#this.sTab##stDef.stFields[ sItem ].fieldName#= "' )>
			<cfif listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) AND stDef.stFields[ sItem ].searchable>
				<cfset this.appendOn( '[optional]' )>
			<cfelseif len( stDef.stFields[ sItem ].default ) OR stDef.stFields[ sItem ].nullable>
				<cfset this.appendOn( '[optional]' )>
			</cfif>
			<cfset this.appendOn( '"' )>
		</cfloop>
		<cfif structKeyExists( stDef.stArgs, "bRowLimit" ) AND stDef.stArgs.bRowLimit>
			<cfset this.appendLine( 'rows="-1"' )>
		</cfif>
	<cfset this.unindent()>
	<cfset this.appendLine( ")>" )>
	<cfset this.appendLine( sRComment )>
</cfif>

<cfreturn replaceList( this.readBuffer( "query_#this.owner#.#stDef.stArgs.sCrudName#", "*" ), ' hint=""', '' )>

</cffunction>