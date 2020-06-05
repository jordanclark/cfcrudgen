<cfscript>
	string function genTag( required struct stDef ) {
		var sItem = "";
		var nSetSelect = "";
		var sLComment = "<!" & "---";
		var sRComment = "---" & ">";
		var sName = "";
		var sQuery = "";
		// overwrite any of the arguments with whatever is passed 
		structAppend( stDef.stArgs, arguments, true );
		// request.log( stDef );
		sName = this.camelCase( "db_" & stDef.stArgs.sCrudName );
		sQuery = replace( sName, "db", "q", "one" );
		// New buffer for crud 
		this.addBuffer( "query_#this.owner#.#stDef.stArgs.sCrudName#", "cfm", true );
		// only execute query tag once 
		this.append( '<cfif isDefined( "thisTag.executionMode" ) AND thisTag.executionMode IS "end">' );
		this.indent();
		this.append( '<cfexit method="exitTemplate">' );
		this.unindent();
		this.append( '</cfif>' );
		this.appendBlank();
		// this.indent();
		this.appendBlank();
		if( listFindNoCase( "select,selectSet", stDef.sType ) ) {
			this.appendLine( '<cfparam name="attributes.query" type="string" default="">' );
		} else if( listFindNoCase( "record,count,exists,insert,update,delete", stDef.sType ) ) {
			this.appendLine( '<cfparam name="attributes.result" type="string" default="">' );
		}
		// add parameters for the input fields 
		for( sItem in stDef.stArgs.lArgFields ) {
			this.appendLine( '<cfparam name="attributes.#stDef.stFields[ sItem ].fieldName#"' );
			// hack in for <cfargument> which wont allow a null "" numeric value to be passed in 
			if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) || ( !len( stDef.stFields[ sItem ].default ) && stDef.stFields[ sItem ].nullable ) ) {
				this.appendOn( ' type="string"' );
			} else {
				this.appendOn( ' type="#stDef.stFields[ sItem ].cfType#"' );
			}
			// give a default value if possible 
			if( listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" ) && listFindNoCase( "update,save", stDef.sType ) ) {
				this.appendOn( ' default="0"' );
			} else if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) && stDef.stFields[ sItem ].searchable ) {
				this.appendOn( ' default=""' );
			} else if( len( stDef.stFields[ sItem ].default ) || stDef.stFields[ sItem ].nullable ) {
				this.appendOn( ' default="#stDef.stFields[ sItem ].default#"' );
			} else {
				this.appendOn( ' required="true"' );
			}
			this.appendOn( ' hint="' );
			if( structKeyExists( stDef.stArgs, "lLikeFields" ) && listFindNoCase( stDef.stArgs.lLikeFields, sItem ) ) {
				this.appendOn( 'Like Matchable. ' );
			}
			if( stDef.stFields[ sItem ].cfType != "string" ) {
				if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) ) {
					this.appendOn( 'Type == #uCase( stDef.stFields[ sItem ].cfType )#.' );
				} else if( !len( stDef.stFields[ sItem ].default ) && stDef.stFields[ sItem ].nullable ) {
					this.appendOn( 'Type == #uCase( stDef.stFields[ sItem ].cfType )#, but == nullable.' );
				}
			}
			this.appendOn( '"' );
			this.appendOn( '>' );
		}
		// parameters for the different query types 
		if( structKeyExists( stDef.stArgs, "bRowLimit" ) && stDef.stArgs.bRowLimit ) {
			this.appendLine( '<cfargument name="rows" type="numeric" default="-1">' );
		}
		// if( structKeyExists( stDef.stArgs, "bDebuggable" ) && stDef.stArgs.bDebuggable ) {
		// 	this.appendLine( '<cfargument name="debug" type="boolean" default="false">' );
		// }
		this.appendBlank();
		// comment to remind what fields are included in select sets 
		if( structKeyExists( stDef.stArgs, "sSetSelect" ) ) {
			this.appendBlank();
			this.appendLine( sLComment );
			for( nSetSelect=1 ; nSetSelect<=stDef.stArgs.nSetSelectLength ; nSetSelect++ ) {
				this.appendLine( 'Select Set ###nSetSelect# = #listGetAt( stDef.stArgs.lSetSelectFields, nSetSelect, "|" )#' );
			}
			this.appendLine( sRComment );
		}
		// build the crud tag 
		this.appendBlank();
		this.appendLine( '<cfquery' );
		if( structKeyExists( stDef.stArgs, "sSetSelect" ) ) {
			this.appendOn( ' name="#sQuery###arguments.selectSet##"' );
		} else {
			this.appendOn( ' name="#sQuery#"' );
		}
		if( stDef.sType == "record" ) {
			this.appendOn( ' maxRows="1"' );
		} else if( structKeyExists( stDef.stArgs, "bRowLimit" ) && stDef.stArgs.bRowLimit ) {
			this.appendOn( ' maxRows="##arguments.rows##"' );
		}
		if( structKeyExists( stDef.stArgs, "bDebuggable" ) && stDef.stArgs.bDebuggable ) {
			this.appendOn( ' debug="##this.debug##"' );
			// this.appendOn( ' result="sql"' );
		}
		if( len( stDef.stArgs.sDSN ) ) {
			this.appendOn( ' dataSource="#stDef.stArgs.sDSN#"' );
		}
		if( structKeyExists( stDef.stArgs, "sTimeOut" ) && len( stDef.stArgs.sTimeOut ) ) {
			this.appendOn( ' timeOut="#stDef.stArgs.sTimeOut#"' );
		}
		this.appendOn( '>' );
		this.indent();
		// append original crud t-sql to cfml code for easy reference 
		this.appendLine( replace( stDef.sSql, this.sNewLine, this.sNewLine & repeatString( this.sTab, this.nIndent ), "all" ) );
		this.unindent();
		this.appendLine( '</cfquery>' );
		this.appendBlank();
		if( stDef.sType == "record" ) {
			this.appendComment( "Build record to return" );
			for( sItem in stDef.stArgs.lSelectFields ) {
				this.appendLine( '<cfset record[ "#stDef.stFields[ sItem ].fieldName#" ] = #sQuery#.#stDef.stFields[ sItem ].fieldName#>' );
			}
			this.appendBlank();
		}
		// return relavant data 
		if( stDef.sType == "record" ) {
			this.appendLine( '<cfset "caller.##attributes.result##" = record>' );
		} else if( listFindNoCase( "select,selectSet", stDef.sType ) ) {
			this.appendLine( '<cfset "caller.##attributes.query##" = #sQuery#>' );
		} else if( stDef.sType == "count" ) {
			this.appendLine( '<cfset "caller.##attributes.result##" = val( #sQuery#.total )>' );
		} else if( stDef.sType == "exists" ) {
			this.appendLine( '<cfset "caller.##attributes.result##" = ( #sQuery#.recordCount GT 0 )>' );
		} else if( stDef.sType == "insert" || stDef.sType == "save" ) {
			this.appendLine( '<cfset "caller.##attributes.result##" = val( #sQuery#.pk_identity )>' );
		} else if( listFindNoCase( "update,delete", stDef.sType ) ) {
			this.appendLine( '<cfset "caller.##attributes.result##" = val( #sQuery#.row_count )>' );
		} else {
			this.appendLine( sLComment & ' no output ' & sRComment );
		}
		this.appendBlank();
		this.appendBlank();
		// create sample code comment 
		if( structKeyExists( stDef.stArgs, "bSampleCode" ) && stDef.stArgs.bSampleCode ) {
			this.appendLine( sLComment );
			this.appendLine( '<cf_db_FOOBAR ' );
			this.indent();
			for( sItem in stDef.stArgs.lArgFields ) {
				this.appendLine( '#stDef.stFields[ sItem ].fieldName#="' );
				if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) && stDef.stFields[ sItem ].searchable ) {
					this.appendOn( '[optional]' );
				} else if( len( stDef.stFields[ sItem ].default ) || stDef.stFields[ sItem ].nullable ) {
					this.appendOn( '[optional]' );
				}
				this.appendOn( '"' );
			}
			if( structKeyExists( stDef.stArgs, "bRowLimit" ) && stDef.stArgs.bRowLimit ) {
				this.appendLine( 'rows="-1"' );
			}
			this.unindent();
			this.appendLine( ">" );
			this.appendLine( sRComment );
		}
		return replaceList( this.readBuffer( "query_#this.owner#.#stDef.stArgs.sCrudName#", "*" ), ' hint=""', '' );
	}
</cfscript>