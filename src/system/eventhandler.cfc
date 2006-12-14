<!-----------------------------------------------------------------------Copyright 2005 - 2006 ColdBox Framework by Luis Majanowww.coldboxframework.com | www.coldboxframework.org-------------------------------------------------------------------------Author 	    :	Luis MajanoDate        :	September 23, 2005Description :	This is a cfc that all event handlers should extendModification History:01/12/2006 - Added fix for whitespace management.06/08/2006 - Updated for coldbox07/29/2006 - Datasource support via getdatsource()-----------------------------------------------------------------------><cfcomponent name="eventhandler" hint="This is the event handler base cfc." output="false" extends="coldbox.system.util.actioncontroller"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->		<cffunction name="init" access="public" returntype="any" output="false">		<!--- memory reference for the request collection --->		<cfset variables.rc = getCollection()>		<!--- UDF Library Call --->		<cfset includeUDF()>		<cfreturn this>	</cffunction><!------------------------------------------- PUBLIC ------------------------------------------->	<!--- ************************************************************* --->		<cffunction name="includeUDF" access="public" hint="Includes the UDF Library if found and exists. Called only by the framework." output="false" returntype="void">		<!--- check if UDFLibraryFile is defined  --->		<cfif getSetting("UDFLibraryFile") neq "">			<!--- Check if file exists on app's includes --->			<cfif fileExists("#getSetting("ApplicationPath",1)#/#getSetting("UDFLibraryFile")#")>				<cfinclude template="/#getSetting("AppMapping")#/#getSetting("UDFLibraryFile")#">			<cfelseif fileExists(ExpandPath("#getSetting("UDFLibraryFile")#"))>				<cfinclude template="#getSetting("UDFLibraryFile")#">			<cfelse>				<cfthrow type="Framework.eventhandler.UDFLibraryNotFoundException" message="Error loading UDFLibraryFile.  The file declared in the config.xml: #getSetting("UDFLibraryFile")# was not found in your application's include directory or in the following location: #ExpandPath(getSetting("UDFLibraryFile"))#. Please make sure you verify the file's location.">			</cfif>		</cfif>	</cffunction>		<!--- ************************************************************* --->		<cffunction name="renderView" access="Public" hint="Facade to renderer.renderView" output="false" returntype="Any">		<!--- ************************************************************* --->		<cfargument name="view" required="false" default="#getvalue('currentView','')#" type="string">			<!--- ************************************************************* --->		<cfreturn getPlugin("renderer").renderView(arguments.view)>	</cffunction>		<!--- ************************************************************* --->	<!------------------------------------------- PRIVATE ------------------------------------------->	</cfcomponent>