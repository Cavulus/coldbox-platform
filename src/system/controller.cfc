<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------
Author 	 		: Luis Majano
Date     		: September 23, 2005 
Last Update 	: December 9, 2006
----------------------------------------------------------------------->
<cfcomponent name="controller" hint="This is the ColdBox Controller. I practically do everything" output="false">
		
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" returntype="any" access="Public" hint="I am the constructor" output="false">
		<cfscript>
		variables.instance = structnew();
		variables.instance.DebugMode = false;
		return this;
		</cfscript>
	</cffunction>
<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getDebugMode" access="public" hint="I Get the current controller debugmode" returntype="boolean"  output="false">
		<cfscript>
			return variables.instance.DebugMode;
		</cfscript>
	</cffunction>

	<cffunction name="setDebugMode" access="public" hint="I set the current controller debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" >
		<cfscript>
			variables.instance.DebugMode = arguments.mode;
		</cfscript>
	</cffunction>
	
	<cffunction name="getSetting" hint="I get a setting from the FW Config structures. Use the FWSetting boolean argument to retrieve from the fwSettingsStruct." access="public" returntype="any" output="false">
		<cfargument name="name" 	    type="string"   	hint="Name of the setting key to retrieve"  >
		<cfargument name="FWSetting"  	type="boolean" 	 	required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if ( arguments.FWSetting and isDefined("application.ColdBox_FWSettingsStruct.#arguments.name#") )
			return Evaluate("application.ColdBox_FWSettingsStruct.#arguments.name#");
		else if ( isDefined("application.ColdBox_configstruct.#arguments.name#") )
			 return Evaluate("application.ColdBox_configstruct.#arguments.name#");
		else
			throw("The setting #arguments.name# does not exist.","FWSetting flag is #arguments.FWSetting#","Framework.SettingNotFoundException");
		</cfscript>
	</cffunction>
	
	<cffunction name="settingExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the configstruct or the fwsettingsStruct." output="false">
		<cfargument name="name" hint="Name of the setting to find." type="string">
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
		if (arguments.FWSetting){
			return isDefined("application.ColdBox_FWSettingsStruct.#arguments.name#");
		}
		else{
			return isDefined("application.ColdBox_configstruct.#arguments.name#");
		}
		</cfscript>
	</cffunction>
		
	<cffunction name="setSetting" access="Public" returntype="any" hint="I set a Global Coldbox setting variable in the configstruct, if it exists it will be overrided. This only sets in the ConfigStruct" output="false">
		<cfargument name="name"  type="string"   hint="The name of the setting" >
		<cfargument name="value" type="any"      hint="The value of the setting (Can be simple or complex)">
		<!--- ************************************************************* --->
		<cfscript>
		"application.Coldbox_configstruct.#arguments.name#" = arguments.value;
		</cfscript>
	</cffunction>
	
	<cffunction name="getPlugin" access="Public" returntype="any" hint="I am the Plugin cfc object factory." output="false">
		<cfargument name="plugin" type="string" hint="The Plugin object's name to instantiate" >
		<!--- ************************************************************* --->
		<cfscript>
		try{
			return CreateObject("component", "plugins.#trim(arguments.plugin)#").init();
		}
		catch(Any e){
			throw("Framework.getPlugin: Error Instantiating Plugin Object (#trim(arguments.plugin)#)","#e.Message# #e.detail#","Framework.InvalidPluginInstantiationException");
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="reqCapture" access="Public" returntype="void" hint="I capture a framework event request." output="false">
		<cfargument name="FORM" hint="The form scope" type="any">
		<cfargument name="URL"  hint="The url scope"  type="any">
		<!--- ************************************************************* --->
		<cfscript>
		request.reqCollection = structNew();
		StructAppend(request.reqCollection, arguments.FORM);
		StructAppend(request.reqCollection, arguments.URL);
		//<!--- Debug Mode Checks --->
		if ( structKeyExists(request.reqCollection,"debugMode") and isBoolean(request.reqCollection.debugmode) ){
			if ( getSetting("debugPassword") eq "")
				setDebugMode(request.reqCollection.debugmode);
			else if ( structKeyExists(request.reqCollection,"debugpass") and compareNoCase(getSetting("debugPassword"),request.reqCollection.debugpass) eq 0 )
				setDebugMode(request.reqCollection.debugmode);
		}

		//<!---Default Event Definition --->
		if ( not structkeyExists(request.reqCollection,"event") )
			request.reqCollection.event = getSetting("DefaultEvent");

		//<!---Event More Than 1 Check, grab the first event instance, other's are discarded --->
		if ( listLen(request.reqCollection.event) gte 2 )
			request.reqCollection.event = getToken(event,1,",");
		</cfscript>
	</cffunction>

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection" type="string">
		<!--- ************************************************************* --->
		<cfscript>
			return isDefined("request.reqCollection.#arguments.name#");
		</cfscript>
	</cffunction>

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection" type="string">
		<cfargument name="defaultValue"
					hint="Default value to return if not found.There are no default values for complex structures. You can send [array][struct][query] and the
						  method will return the empty complex variable.Please remember to include the brackets, syntax sensitive.You can also send complex variables
						  as the defaultValue argument."
					type="any" required="No" default="NONE">
		<!--- ************************************************************* --->
		<cfscript>
			if ( isDefined("request.reqCollection.#arguments.name#") ){
				return Evaluate("request.reqCollection.#arguments.name#");
			}
			else if ( isSimpleValue(arguments.defaultValue) and arguments.defaultValue eq "NONE" )
				throw("The variable: #arguments.name# is undefined in the request collection.","","Framework.ValueNotInRequestCollectionException");
			else if ( isSimpleValue(arguments.defaultValue) ){
				if ( refind("\[[A-Za-z]*\]", arguments.defaultValue) ){
					if ( findnocase("array", arguments.defaultvalue) )
						return ArrayNew(1);
					else if ( findnocase("struct", arguments.defaultvalue) )
						return StructNew();
					else if ( findnocase("query", arguments.defaultvalue) )
						return QueryNew("");
				}
				else
					return arguments.defaultValue;
			}
			else
				return arguments.defaultValue;
		</cfscript>
	</cffunction>

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set." type="string" >
		<cfargument name="value" hint="The value of the variable to set" type="Any" >
		<!--- ************************************************************* --->
		<cfscript>
			"request.reqCollection.#arguments.name#" = arguments.value;
		</cfscript>
	</cffunction>

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<!--- ************************************************************* --->
		<cfscript>
			structDelete(request.reqCollection,"#arguments.name#");
		</cfscript>
	</cffunction>

	<cffunction name="runEvent" returntype="void" access="Public" hint="I am an event handler runnable factory. If no event is passed in then it will run the default event from the config.xml.">
		<cfargument name="event" hint="The event to run. If no current event is set, use the default event from the config.xml" type="string" required="no" default="#getValue("event")#">
		<!--- ************************************************************* --->
		<cfset var objEventHandler = "">
		<cfset var EventBean = "">
		<!--- Start Timer --->
		<cfmodule template="includes/timer.cfm" timertag="invoking runEvent [#arguments.event#]">
			<cfscript>
			//Get registered handler
			EventBean = getPlugin("settings").getRegisteredHandler(arguments.event);
			try{
				objEventHandler = CreateObject("component","#getSetting("HandlersInvocationPath")#.#EventBean.getHandler()#").init();
			}
			catch(Any e){
				throw("Error Instantiating Event Handler: (#EventBean.getName()#)","CFCPath: #getSetting("HandlersInvocationPath")# ; #e.Detail# #e.Message#","Framework.EventHandlerInstantiationException");
			}
			//Run the event handler method.
			evaluate("objEventHandler.#EventBean.getMethod()#()");
			</cfscript>
		</cfmodule>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
</cfcomponent>