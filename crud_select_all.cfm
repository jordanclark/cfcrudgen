<cfscript>	
	boolean function selectAllCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.selectAllSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	) {
		arguments.lFilterFields= "!PK";
		arguments.lSelectFields= "*";
		return this.selectCrud( argumentcollection= arguments );
	}
</cfscript>