<!-----------------------------------------------------------------------********************************************************************************Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corpwww.coldboxframework.com | www.luismajano.com | www.ortussolutions.com********************************************************************************Author 	 :	Luis MajanoDate     :	September 23, 2005Description :	This is a utilities library that are file related, most of them.Modification History:08/01/2006 - Added createFile(),getFileExtension()10/10/2006 - Returntypes review.-----------------------------------------------------------------------><cfcomponent name="Utilities"       		 hint="This is a Utilities CFC"       		 extends="coldbox.system.plugin"       		 output="false"       		 cache="true"       		 cachetimeout="5"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cffunction name="init" access="public" returntype="Utilities" output="false">		<cfargument name="controller" type="any" required="true">		<cfset super.Init(arguments.controller) />		<cfset setpluginName("Utilities Plugin")>		<cfset setpluginVersion("1.0")>		<cfset setpluginDescription("This plugin provides various file/system/java utilities")>		<cfreturn this>	</cffunction><!------------------------------------------- UTILITY METHODS ------------------------------------------->	<cffunction name="isCFUUID" output="false" returntype="boolean" hint="Checks if a passed string is a valid UUID.">		<cfargument name="inStr" type="string" required="true" />		<cfreturn reFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", inStr) />	</cffunction>	<!--- ************************************************************* --->		<cffunction name="isSSL" output="false" returntype="boolean" hint="Tells you if you are in SSL mode or not.">		<cfscript>			if( isBoolean(cgi.server_port_secure) and cgi.server_port_secure ){				return true;			}			else{				return false;			}		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="IsEmail" access="public" returntype="boolean" output="false" hint="author Jeff Guillaume (jeff@kazoomis.com): Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains)">		<cfargument name="str" type="any" required="true">		<cfscript>		/**		 * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).		 * Update by David Kearns to support '		 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.		 *		 * @param str 	 The string to check. (Required)		 * @return Returns a boolean.		 * @author Jeff Guillaume (jeff@kazoomis.com)		 * @version 2, August 15, 2002		 */	    //supports new top level tlds		if (REFindNoCase("^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",arguments.str))			return TRUE;		else			return FALSE;		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="IsURL" access="public" returntype="boolean" output="false" hint="author Nathan Dintenfass (nathan@changemedia.com): A quick way to test if a string is a URL">		<cfargument name="str" type="any" required="true">		<cfscript>		/**		 * A quick way to test if a string is a URL		 *		 * @param stringToCheck 	 The string to check.		 * @return Returns a boolean.		 * @author Nathan Dintenfass (nathan@changemedia.com)		 * @version 1, November 22, 2001		 */	    return REFindNoCase("^(((https?:|ftp:|gopher:)\/\/))[-[:alnum:]\?%,\.\/&##!@:=\+~_]+[A-Za-z0-9\/]$",arguments.str) NEQ 0;		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="sleeper" access="public" returntype="void" output="false" hint="Make the main thread of execution sleep for X amount of seconds.">		<!--- ************************************************************* --->		<cfargument name="milliseconds" type="numeric" required="yes" hint="Milliseconds to sleep">		<!--- ************************************************************* --->		<cfset CreateObject("java", "java.lang.Thread").sleep(arguments.milliseconds)>	</cffunction>	<!--- ************************************************************* --->		<cffunction name="createArray" access="public" returntype="array" hint="Create an Array from conventions [ elem, elem ]" output="false">		<!--- ************************************************************* --->		<cfargument name="str" type="string" required="true" hint="The convention string to create an array from. This is basic JSON syntax">		<!--- ************************************************************* --->		<!--- Clean [] --->		<cfscript>			var cleanList = "";			var i = 1;			var cleanArray = ArrayNew(1);			var listLength = 0;			var quoteChar = "'";						//clean List			cleanList = reReplace( arguments.str, '^\[|\]$', '', "All");			//set length			listLength = listlen(cleanList);			//create array elements			for (i=1; i lte listLength; i=i+1){				ArrayAppend(cleanArray, reReplace( trim(listgetAt(cleanList,i)) , '^\#quoteChar#|\#quoteChar#$',"", "All" ) );			}			//return array			return cleanArray;		</cfscript>	</cffunction>		<!--- ************************************************************* --->		<cffunction name="createStruct" access="public" returntype="struct" hint="Create a Structure from conventions { key: value, key2= value }" output="false">		<!--- ************************************************************* --->		<cfargument name="str" type="string" required="true" hint="The convention string to create a struct from. This is basic JSON syntax">		<!--- ************************************************************* --->		<!--- Clean {} --->		<cfscript>			var cleanList = "";			var i = 1;			var newStructure = structnew();			var structList = "";			var quoteChar = "'";			var listLength = "";			var value = "";						//clean List			cleanList = reReplace( arguments.str, '^\{|\}$', '', "All");			//set length			listLength = listlen(cleanList);			//create array elements			for (i=1; i lte listLength; i=i+1){				structList = listgetAt(cleanList,i);				if ( find(":",structList) ){					value = reReplace( trim(getToken(structList,2,":")) , '^\#quoteChar#|\#quoteChar#$',"", "All" );					structInsert(newStructure, trim(getToken(structList,1,":")), value );				}				else{					value = reReplace( trim(getToken(structList,2,"=")) , '^\#quoteChar#|\#quoteChar#$',"", "All" );					structInsert(newStructure, trim(getToken(structList,1,"=")), value );				}				}			//return structure			return newStructure;		</cfscript>	</cffunction>	<!--- ************************************************************* --->		<cffunction name="_serialize" access="public" returntype="string" output="false" hint="Serialize complex objects that implement serializable. Returns a binary string.">		<!--- ************************************************************* --->		<cfargument name="ComplexObject" type="any" required="true" hint="Any coldfusion primative data type and if cf8 componetns."/>        <!--- ************************************************************* --->		<cfscript>            var ByteArrayOutput = CreateObject("java", "java.io.ByteArrayOutputStream").init();            var ObjectOutput    = CreateObject("java", "java.io.ObjectOutputStream").init(ByteArrayOutput);                       /* Serialize the incoming object. */            ObjectOutput.writeObject(arguments.ComplexObject);            ObjectOutput.close();            return ToBase64(ByteArrayOutput.toByteArray());        </cfscript>    </cffunction>        <!--- Serialize an object to a file --->    <cffunction name="_serializeToFile" access="public" returntype="void" output="false" hint="Serialize complex objects that implement serializable, into a file.">		<!--- ************************************************************* --->		<cfargument name="ComplexObject" type="any" required="true" hint="Any coldfusion primative data type and if cf8 componetns."/>        <cfargument name="fileDestination" required="true" type="string" hint="The absolute path to the destination file to write to">        <!--- ************************************************************* --->		<cfscript>            var FileOutput = CreateObject("java", "java.io.FileOutputStream").init("#arguments.fileDestination#");            var ObjectOutput    = CreateObject("java", "java.io.ObjectOutputStream").init(FileOutput);                       /* Serialize the incoming object. */            ObjectOutput.writeObject(arguments.ComplexObject);            ObjectOutput.close();        </cfscript>    </cffunction>        <!--- Deserialize a byte array --->    <cffunction name="_deserialize" access="public" returntype="Any" output="false" hint="Deserialize a byte array">        <!--- ************************************************************* --->		<cfargument name="BinaryString" type="string" required="true" hint="The byte array string to deserialize"/>        <!--- ************************************************************* --->		<cfscript>            var ByteArrayInput = CreateObject("java", "java.io.ByteArrayInputStream").init(toBinary(arguments.BinaryString));    		var ObjectInput    = CreateObject("java", "java.io.ObjectInputStream").init(ByteArrayInput);	                      	/* Return inflated Object. */            return ObjectInput.readObject();        </cfscript>    </cffunction>         <!--- Deserialize a byte array --->    <cffunction name="_deserializeFromFile" access="public" returntype="Any" output="false" hint="Deserialize a byte array from a file">        <!--- ************************************************************* --->		<cfargument name="fileSource" required="true" type="string" hint="The absolute path to the source file to deserialize">        <!--- ************************************************************* --->		<cfscript>			var object = "";            var FileInput = CreateObject("java", "java.io.FileInputStream").init("#arguments.fileSource#");    		var ObjectInput    = CreateObject("java", "java.io.ObjectInputStream").init(FileInput);	                      	/* Return inflated Object. */           	object = ObjectInput.readObject();           	ObjectInput.close();           	            return object;        </cfscript>    </cffunction><!------------------------------------------- OS SPECIFIC METHODS ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="getOSFileSeparator" access="public" returntype="string" output="false" hint="Get the operating system's file separator character">		<cfscript>		var objFile =  createObject("java","java.lang.System");		return objFile.getProperty("file.separator");		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getOSPathSeparator" access="public" returntype="string" output="false" hint="Get the operating system's path separator character.">		<cfscript>		var objFile =  createObject("java","java.lang.System");		return objFile.getProperty("path.separator");		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getOSName" access="public" returntype="string" output="false" hint="Get the operating system's name">		<cfscript>		var objFile =  createObject("java","java.lang.System");		return objFile.getProperty("os.name");		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getInetHost" access="public" returntype="string" output="false" hint="Get the hostname of the executing machine.">		<cfscript>		return CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getIPAddress" access="public" returntype="string" output="false" hint="Get the ip address of the executing hostname machine.">		<cfscript>		return CreateObject("java", "java.net.InetAddress").getLocalHost().getHostAddress();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getJavaRuntime" access="public" returntype="string" output="false" hint="Get the java runtime version">		<cfscript>		return CreateObject("java", "java.lang.System").getProperty("java.runtime.version");		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getJavaVersion" access="public" returntype="string" output="false" hint="Get the java version.">		<cfscript>		return CreateObject("java", "java.lang.System").getProperty("java.version");		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getJVMfreeMemory" access="public" returntype="string" output="false" hint="Get the JVM's free memory.">		<cfscript>		return CreateObject("java", "java.lang.Runtime").getRuntime().freeMemory();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getJVMTotalMemory" access="public" returntype="string" output="false" hint="Get the JVM's total memory.">		<cfscript>		return CreateObject("java", "java.lang.Runtime").getRuntime().totalMemory();		</cfscript>	</cffunction>	<!--- ************************************************************* ---><!------------------------------------------- CFFILE FACADES ------------------------------------------->	<!--- Upload File --->	<cffunction name="uploadFile" access="public" hint="Facade to upload to a file, returns the cffile variable." returntype="any" output="false">		<!--- ************************************************************* --->		<cfargument name="FileField"         type="string" 	required="yes" 		hint="The name of the form field used to select the file">		<cfargument name="Destination"       type="string" 	required="yes"      hint="The absolute path to the destination.">		<cfargument name="NameConflict"      type="string"  required="false" default="makeunique" hint="Action to take if filename is the same as that of a file in the directory.">		<cfargument name="Accept"            type="string"  required="false" default="" hint="Limits the MIME types to accept. Comma-delimited list.">		<!--- *************************************** --->		<cffile action="upload" 				filefield="#arguments.FileField#" 				destination="#arguments.Destination#" 				nameconflict="#arguments.NameConflict#" 				accept="#arguments.Accept#">		<cfreturn cffile>	</cffunction>   	<!--- ************************************************************* --->	<cffunction name="readFile" access="public" hint="Facade to Read a file's content" returntype="Any" output="false">		<!--- ************************************************************* --->		<cfargument name="FileToRead"	 		type="String"  required="yes" 	 hint="The absolute path to the file.">		<cfargument name="ReadInBinaryFlag" 	type="boolean" required="false" default="false" hint="Read in binary flag.">		<cfargument name="CharSet"				type="string"  required="false" default="" hint="CF File CharSet Encoding to use.">		<cfargument name="CheckCharSetFlag" 	type="boolean" required="false" default="false" hint="Check the charset.">		<!--- ************************************************************* --->		<cfset var FileContents = "">		<!--- Verify File Encoding to use --->		<cfif arguments.CheckCharSetFlag><cfset arguments.charset = checkCharSet(arguments.CharSet)></cfif>		<!--- Binary Test --->		<cfif ReadInBinaryFlag>			<cffile action="readbinary" file="#arguments.FileToRead#" variable="FileContents">		<cfelse>			<cfif arguments.charset neq "">				<cffile action="read" file="#arguments.FileToRead#" variable="FileContents" charset="#arguments.charset#">			<cfelse>				<cffile action="read" file="#arguments.FileToRead#" variable="FileContents">			</cfif>		</cfif>		<cfreturn FileContents>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="saveFile" access="public" hint="Facade to save a file's content" returntype="void" output="false">		<!--- ************************************************************* --->		<cfargument name="FileToSave"	 		type="any"  	required="yes" 	 hint="The absolute path to the file.">		<cfargument name="FileContents" 		type="any"  	required="yes"   hint="The file contents">		<cfargument name="CharSet"				type="string"  	required="false" default="utf-8" hint="CF File CharSet Encoding to use.">		<cfargument name="CheckCharSetFlag" 	type="boolean" required="false" default="false" hint="Check the charset.">		<!--- ************************************************************* --->		<!--- Verify File Encoding to use --->		<cfif arguments.CheckCharSetFlag><cfset arguments.charset = checkCharSet(arguments.CharSet)></cfif>		<cffile action="write" file="#arguments.FileToSave#" output="#arguments.FileContents#" charset="#arguments.charset#">	</cffunction>	<!--- ************************************************************* --->	<cffunction name="appendFile" access="public" hint="Facade to append to a file's content" returntype="void" output="false">		<!--- ************************************************************* --->		<cfargument name="FileToSave"	 		type="any"  required="yes" 	 hint="The absolute path to the file.">		<cfargument name="FileContents" 		type="any"  required="yes"   hint="The file contents">		<cfargument name="CharSet"				type="string"  	required="false" default="utf-8" hint="CF File CharSet Encoding to use.">		<cfargument name="CheckCharSetFlag" 	type="boolean" required="false" default="false" hint="Check the charset.">		<!--- ************************************************************* --->		<!--- Verify File Encoding to use --->		<cfif arguments.CheckCharSetFlag><cfset arguments.charset = checkCharSet(arguments.CharSet)></cfif>		<cffile action="append" file="#arguments.FileToSave#" output="#arguments.FileContents#" charset="#arguments.charset#">	</cffunction>	<!--- ************************************************************* ---><!------------------------------------------- FILE/DIRECTORY SPECIFIC METHODS ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="FileLastModified" access="public" returntype="string" output="false" hint="Get the last modified date of a file">		<!--- ************************************************************* --->		<cfargument name="filename" type="string" required="yes">		<!--- ************************************************************* --->		<cfscript>		var objFile =  createObject("java","java.io.File").init(JavaCast("string",arguments.filename));		// Calculate adjustments fot timezone and daylightsavindtime		var Offset = ((GetTimeZoneInfo().utcHourOffset)+1)*-3600;		// Date is returned as number of seconds since 1-1-1970		return DateAdd('s', (Round(objFile.lastModified()/1000))+Offset, CreateDateTime(1970, 1, 1, 0, 0, 0));		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="FileSize" access="public" returntype="string" output="false" hint="Get the filesize of a file.">		<!--- ************************************************************* --->		<cfargument name="filename"   type="string" required="yes">		<cfargument name="sizeFormat" type="string" required="no" default="bytes"					hint="Available formats: [bytes][kbytes][mbytes][gbytes]">		<!--- ************************************************************* --->		<cfscript>		var objFile =  createObject("java","java.io.File");		objFile.init(JavaCast("string", filename));		if ( arguments.sizeFormat eq "bytes" )			return objFile.length();		if ( arguments.sizeFormat eq "kbytes" )			return (objFile.length()/1024);		if ( arguments.sizeFormat eq "mbytes" )			return (objFile.length()/(1048576));		if ( arguments.sizeFormat eq "gbytes" )			return (objFile.length()/1073741824);		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="removeFile" access="public" hint="Remove a file using java.io.File" returntype="boolean" output="false">		<!--- ************************************************************* --->		<cfargument name="filename"	 		type="string"  required="yes" 	 hint="The absolute path to the file.">		<!--- ************************************************************* --->		<cfscript>		var fileObj = createObject("java","java.io.File").init(JavaCast("string",arguments.filename));		return fileObj.delete();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="createFile" access="public" hint="Create a new empty fileusing java.io.File." returntype="void" output="false">		<!--- ************************************************************* --->		<cfargument name="filename"	 		type="String"  required="yes" 	 hint="The absolute path of the file to create.">		<!--- ************************************************************* --->		<cfscript>		var fileObj = createObject("java","java.io.File").init(JavaCast("string",arguments.filename));		fileObj.createNewFile();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="FileCanWrite" access="public" hint="Check wether you can write to a file" returntype="boolean" output="false">		<!--- ************************************************************* --->		<cfargument name="Filename"	 type="String"  required="yes" 	 hint="The absolute path of the file to check.">		<!--- ************************************************************* --->		<cfscript>		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.Filename));		return FileObj.canWrite();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="FileCanRead" access="public" hint="Check wether you can read a file" returntype="boolean" output="false">		<!--- ************************************************************* --->		<cfargument name="Filename"	 type="String"  required="yes" 	 hint="The absolute path of the file to check.">		<!--- ************************************************************* --->		<cfscript>		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.Filename));		return FileObj.canRead();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="isFile" access="public" hint="Checks whether the filename argument is a file or not." returntype="boolean" output="false">		<!--- ************************************************************* --->		<cfargument name="Filename"	 type="String"  required="yes" 	 hint="The absolute path of the file to check.">		<!--- ************************************************************* --->		<cfscript>		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.Filename));		return FileObj.isFile();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="isDirectory" access="public" hint="Check wether the filename argument is a directory or not" returntype="boolean" output="false">		<!--- ************************************************************* --->		<cfargument name="Filename"	 type="String"  required="yes" 	 hint="The absolute path of the file to check.">		<!--- ************************************************************* --->		<cfscript>		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.Filename));		return FileObj.isDirectory();		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getAbsolutePath" access="public" output="false" returntype="string" hint="Turn any system path, either relative or absolute, into a fully qualified one">		<!--- ************************************************************* --->		<cfargument name="path" type="string" required="true" hint="Abstract pathname">		<!--- ************************************************************* --->		<cfscript>		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.path));		if(FileObj.isAbsolute()){			return arguments.path;		}		else{			return ExpandPath(arguments.path);		}		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="checkCharSet" access="public" output="false" returntype="string" hint="Check a charset with valid CF char sets, if invalid, it returns the framework's default character set">		<!--- ************************************************************* --->		<cfargument name="charset" type="string" required="true" hint="Charset to check">		<!--- ************************************************************* --->		<cfscript>		if ( listFindNoCase(getController().getSetting("AvailableCFCharacterSets",1),lcase(arguments.charset)) )			return getController().getSetting("DefaultFileCharacterSet",1);		else			return arguments.charset;		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="ripExtension" access="public" returntype="string" output="false" hint="Rip the extension of a filename.">		<cfargument name="filename" type="string" required="true">		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>	</cffunction>	<!--- ************************************************************* ---></cfcomponent>