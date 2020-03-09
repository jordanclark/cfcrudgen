<cfscript>
	string function genCFC( required struct stDef ) {
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
		this.append( '<cffunction name="#stDef.stArgs.sUdfName#" output="false"' );
		for( sItem in "access,roles,display" ) {
			if( structKeyExists( stDef.stArgs, "sUdf" & sItem ) ) {
				this.appendOn( ' #sItem#="#stDef.stArgs[ 'sUdf' & sItem ]#"' );
			}
		}
		if( stDef.sType == "record" ) {
			this.appendOn( ' returnType="struct">' );
		} else if( listFindNoCase( "select,selectSet,paginate", stDef.sType ) ) {
			this.appendOn( ' returnType="query">' );
		} else if( stDef.sType == "exists" ) {
			this.appendOn( ' returnType="boolean">' );
		} else if( listFindNoCase( "insert,merge,upsert,save", stDef.sType ) && stDef.stArgs.bIdentityField ) {
			this.appendOn( ' returnType="numeric">' );
		} else if( listFindNoCase( "count,update,delete,remove", stDef.sType ) ) {
			this.appendOn( ' returnType="numeric">' );
		} else {
			this.appendOn( '>' );
		}
		// this.indent();
		this.appendBlank();
		if( stDef.sType == "paginate" ) {
			this.appendLine( '<cfargument name="page" type="numeric" default="1">' );
			this.appendLine( '<cfargument name="pageSize" type="numeric" default="100">' );
		}
		// add parameters for the input fields 
		for( sItem in stDef.stArgs.lArgFields ) {
			this.appendLine( '<cfargument name="#stDef.stFields[ sItem ].fieldName#"' );
			// hack in for <cfargument> which wont allow a null "" numeric value to be passed in 
			if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem )
				OR ( !len( stDef.stFields[ sItem ].default ) && stDef.stFields[ sItem ].nullable )
				OR listFindNoCase( "merge,upsert,save", stDef.sType )
				OR listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" )
			) {
				this.appendOn( ' type="string"' );
			} else {
				this.appendOn( ' type="#stDef.stFields[ sItem ].cfType#"' );
			}
			// give a default value if possible 
			if( listFindNoCase( "count,exists,remove,search,select,paginate", stDef.sType ) ) {
				this.appendOn( ' default=""' );
			} else if( listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" ) && listFindNoCase( "update,save,merge,upsert", stDef.sType ) ) {
				this.appendOn( ' default="0"' );
			} else if( listFindNoCase( stDef.stArgs.lPrimaryKeys, sItem ) ) {
				this.appendOn( ' required="true"' );
			} else if( len( stDef.stFields[ sItem ].default ) || stDef.stFields[ sItem ].nullable ) {
				this.appendOn( ' default="#stDef.stFields[ sItem ].default#"' );
			} else if( listFindNoCase( "update,merge,upsert,save", stDef.sType ) ) {
				this.appendOn( ' default=""' );
			} else {
				this.appendOn( ' required="true"' );
			}
			this.appendOn( ' hint="' );
			if( structKeyExists( stDef.stArgs, "lLikeFields" ) && listFindNoCase( stDef.stArgs.lLikeFields, sItem ) ) {
				this.appendOn( 'Like Matchable. ' );
			}
			if( stDef.stFields[ sItem ].cfType != "string" ) {
				if( listFindNoCase( stDef.stArgs.lArgsOptional, sItem ) || listFindNoCase( "merge,upsert,save", stDef.sType ) ) {
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
		// this.appendBlank();
		// comment to remind what fields are included in select sets 
		if( structKeyExists( stDef.stArgs, "sSetSelect" ) ) {
			this.appendBlank();
			this.appendLine( sLComment );
			for ( nSetSelect=1 ; nSetSelect<=stDef.stArgs.nSetSelectLength ; nSetSelect++ ) {
				this.appendLine( 'Select Set ###nSetSelect# = #listGetAt( stDef.stArgs.lSetSelectFields, nSetSelect, "|" )#' );
			}
			this.appendLine( sRComment );
		}
		// SET VAR for ACF or "classic" scope mode in lucee 
		// if( structKeyExists( stDef.stArgs, "sSetSelect" ) ) {
		// 	this.appendLine( '<cfset var #sQuery###arguments.selectSet## = 0>' );
		// } else {
		// 	this.appendLine( '<cfset var #sQuery# = 0>' );
		// }
		// if( structKeyExists( stDef.stArgs, "bDebuggable" ) && stDef.stArgs.bDebuggable ) {
		// 	this.appendLine( '<cfset var sql = 0>' );
		// }
		if( listFindNoCase( "merge,upsert,save", stDef.sType ) ) {
			for( sItem in stDef.stArgs.lArgFields ) {
				if( listFindNoCase( stDef.stFields[ sItem ].attribs, "identity" ) ) {
					this.appendBlank();
					this.append( "<cfif arguments.#stDef.stFields[ sItem ].fieldName# == """" || arguments.#stDef.stFields[ sItem ].fieldName# == ""0""><cfset arguments.#stDef.stFields[ sItem ].fieldName# = ""null""></cfif>" );
				}
			}
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
			this.appendLine( '<cfset var record = {' );
			c = "";
			for( sItem in stDef.stArgs.lSelectFields ) {
				this.appendLine( '#c##stDef.stFields[ sItem ].fieldName#= #sQuery#.#stDef.stFields[ sItem ].fieldName#' );
				c = ",";
			}
			this.appendLine( '}>' );
			this.appendBlank();
		}
		// return relavant data 
		if( stDef.sType == "record" ) {
			this.appendLine( '<cfreturn record>' );
		} else if( listFindNoCase( "select,selectSet,paginate", stDef.sType ) ) {
			this.appendLine( '<cfreturn #sQuery#>' );
		} else if( stDef.sType == "count" ) {
			this.appendLine( '<cfreturn val( #sQuery#.total )>' );
		} else if( stDef.sType == "exists" ) {
			this.appendLine( '<cfreturn ( #sQuery#.recordCount > 0 )>' );
		} else if( listFindNoCase( "insert,merge,upsert,save", stDef.sType ) && stDef.stArgs.bIdentityField ) {
			this.appendLine( '<cfreturn val( #sQuery#.pk_identity )>' );
		} else if( listFindNoCase( "update,delete,remove", stDef.sType ) ) {
			this.appendLine( '<cfreturn val( #sQuery#.row_count )>' );
		} else {
			this.appendLine( sLComment & ' no output ' & sRComment );
			this.appendLine( '<cfreturn>' );
		}
		this.appendBlank();
		// this.unindent();
		this.appendLine( '</cffunction>' );
		// add real function name to cfc 
		// this.appendBlank();
		// this.appendLine( '<cfset this.#right( stDef.stArgs.sUdfName, len( stDef.stArgs.sUdfName ) - 2 )# = variables.#stDef.stArgs.sUdfName#>' );
		// this.appendLine( '<cfset structDelete( variables, "#stDef.stArgs.sUdfName#" )>' );
		this.appendBlank();
		// create sample code comment 
		if( structKeyExists( stDef.stArgs, "bSampleCode" ) && stDef.stArgs.bSampleCode ) {
			this.appendLine( sLComment );
			this.appendLine( '<cfset foo= BOOT.crud( "#stDef.stArgs.sTableName#.#right( stDef.stArgs.sUdfName, len( stDef.stArgs.sUdfName ) - 2 )#" )(' );
			this.indent();
			for( sItem in stDef.stArgs.lArgFields ) {
				this.appendLine( ',#this.sTab##stDef.stFields[ sItem ].fieldName#= "' );
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
			this.appendLine( ")>" );
			this.appendLine( sRComment );
		}
		return replaceList( this.readBuffer( "query_#this.owner#.#stDef.stArgs.sCrudName#", "*" ), ' hint=""', '' );
	}
</cfscript>