
<cffunction name="sql" output="false">

<cfargument name="sCrudName" type="string" required="true">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="sSql" type="string" required="true">
<cfargument name="lFilterFields" type="string" default="">
<cfargument name="lArgFields" type="string" default="">

<cfset structAppend( arguments, this.stDefaults, false )>

<!--- New buffer for crud --->
<cfset this.addBuffer( arguments.sCrudName, "sql", true )>

<!--- Build the comments --->
<!--- <cfset this.appendBlank()>
<cfset this.appendDivide()>
<cfset this.appendCommentLine( "Execute arbitrary SQL code" )>
<cfset this.appendCommentLine( "based on fields: #replace( arguments.lFilterFields, ',', ', ', 'all' )#" )>
<cfset this.appendDivide()>
<cfset this.appendBlank()> --->

<!--- Here is the meat and bones of it all --->
	<cfset this.append( attributes.sSql )>
	
<cfset this.appendBlank()>

<!--- Store Param definition --->
<cfset this.addDefinition( "sql", arguments, this.readBuffer( arguments.sCrudName ) )>

<!--- Generate query tag at the same time --->
<cfif structKeyExists( arguments, "sQueryTagFileName" )>
	<!--- <cfset this.generateQueryTag( arguments.sCrudName, arguments.sQueryTagFileName )> --->
	<cfset this.writeDefinition( arguments.sCrudName, arguments.sQueryTagFileName, "CFC" )>
<cfelseif structKeyExists( arguments, "sTagDir" )>
	<!--- <cfset this.generateQueryTag( arguments.sCrudName, arguments.sQueryTagFileName )> --->
	<cfset this.writeDefinition( arguments.sCrudName, "#arguments.sTagDir#/#arguments.sCrudName#/#arguments.sFileName#", "CFC" )>
</cfif>

<cfreturn>

</cffunction>