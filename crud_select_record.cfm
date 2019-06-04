
<cffunction name="selectRecordCrud" output="false" returnType="string">

<cfargument name="sTableName" type="string" required="true">
<cfargument name="sCommonName" type="string" default="#arguments.sTableName#">
<cfargument name="sCrudName" type="string" default="#arguments.sCommonName##this.selectRecordSuffix#">
<cfargument name="sFileName" type="string" default="dbg_#lCase( arguments.sCrudName )#.cfm">
<cfargument name="lFilterFields" type="string" default="!PK">
<cfargument name="lSelectFields" type="string" default="*">
<cfargument name="bSearchFields" type="boolean" default="false">
<cfargument name="sOrderBy" type="string" default="">

<cfset arguments.bRowLimit = false>
<cfset arguments.sType = "record">

<cfreturn this.selectCrud( argumentCollection = arguments )>

</cffunction>