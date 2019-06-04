
<cffunction name="selectAllCrud" output="false" returnType="string">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.selectAllSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">

<cfset arguments.lFilterFields = "!PK">
<cfset arguments.lSelectFields = "*">

<cfreturn this.selectCrud( argumentcollection = arguments )>

</cffunction>