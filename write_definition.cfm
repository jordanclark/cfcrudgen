<cffunction name="writeDefinition" output="false">

	<cfargument name="lCrudDefs" type="string" required="true">
	<cfargument name="sFileName" type="string" required="true">
	<cfargument name="sType" type="string" required="true">
	<cfargument name="sComponent" type="string" default="">

	<cfset var success = true>
	<cfset var sOutput = "">		
	<cfset var sCrud = "">
	<cfset var stDef = "">

	<cftry>
		<cfif arguments.sType IS "CFC">
			<cfif len( arguments.sComponent )>
				<cfset sOutput = sOutput & '<cfcomponent displayname="#arguments.sComponent#" output="false">' & this.sNewLine />
			</cfif>
			<cfloop index="sCrud" list="#arguments.lCrudDefs#">
				<cfset stDef = this.stDefinitions[ sCrud ]>
				<cfset stDef.stArgs.sFilename = arguments.sFilename>
				<cfset sOutput = sOutput & this.genCFC( stDef )>
			</cfloop>
			<cfif len( arguments.sComponent )>
				<cfset sOutput = sOutput & this.sNewLine & '</cfcomponent>' />
			</cfif>
		<cfelseif arguments.sType IS "CFTAG">
			<cfset stDef = this.stDefinitions[ listFirst( arguments.lCrudDefs ) ]>
			<cfset stDef.stArgs.sFilename = arguments.sFilename>
			<cfset sOutput = this.genTag( stDef )>
		</cfif>
		<cfset sOutput = trim( replaceList( htmlEditFormat( sOutput, -1 ), '&lt;,&gt;,&quot;,&amp;', '<,>,",&' ) ) />
		<!--- <cfoutput>#htmlCodeFormat( sOutput )#</cfoutput> --->
		<cfif NOT directoryExists( getDirectoryFromPath( arguments.sFileName ) )>
			<cfset directoryCreate( getDirectoryFromPath( arguments.sFileName ), true, true )>
		</cfif>
		<cfset fileWrite( arguments.sFileName, sOutput )>
		<cfcatch>
			<cfset success= false>
		</cfcatch>
	</cftry>
	<cfreturn success>
</cffunction>