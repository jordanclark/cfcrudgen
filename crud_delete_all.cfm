
<cffunction name="deleteAllCrud" access="package" output="false" returnType="string">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.deleteAllSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">

<cfset arguments.lFilterFields = "!PK">

<cfreturn this.deleteCrud( argumentCollection = arguments )>

</cffunction>