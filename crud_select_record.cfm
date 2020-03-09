<cfscript>
	boolean function selectRecordCrud(
		required string sTableName
	,	string sCommonName= arguments.sTableName
	,	string sCrudName= "#arguments.sCommonName##this.selectRecordSuffix#"
	,	string sFileName= "dbg_#lCase( arguments.sCrudName )#.cfm"
	,	string lFilterFields= "!PK"
	,	string lSelectFields= "*"
	,	boolean bSearchFields= false
	,	string sOrderBy= ""
	) {
		arguments.bRowLimit= false;
		arguments.sType= "record";
		return this.selectCrud( argumentCollection= arguments );
	}
</cfscript>