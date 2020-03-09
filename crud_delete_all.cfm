<cfscript>
	boolean function deleteAllCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.deleteAllSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	) {
		arguments.lFilterFields= "!PK";
		return this.deleteCrud( argumentCollection= arguments );
	}
</cfscript>