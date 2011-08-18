<cfcomponent displayname="boxcar" output="false">
	<!--- 
	Copyright: Communication Freedom, LLC - http://www.communicationfreedom.com
	Author: Mark Jacobsen - http://www.markjacobsen.net
	Permalink: http://www.communicationfreedom.com/go/download/boxcar-cfc/
	
	Free to use, modify, redistribute.  Must keep copyright and note modifications.
	If this helped you out or saved you time, please consider...
	1) Donating: http://www.communicationfreedom.com/go/donate/
	2) Shoutout on twitter: @MarkJacobsen or @cffreedom
	3) Linking to: http://www.communicationfreedom.com/go/download/boxcar-cfc/
	
	Change Log:
	2011-08-06 	http://www.markjacobsen.net 	Released
	2011-08-08 	http://www.markjacobsen.net		Implemented msgId arguments
												Added getMsgId() for default msgId value
												Added logIt() method - user needs to implement
	--->
	
	<!---
	Set these 2 values to your defaults. You can instantiate different instances
	with different values via the init(key, secret) method
	--->
	<cfset THIS.sApiKey = "" />
	<cfset THIS.sApiSecret = "" />
	
	
	<cffunction name="init" access="public" output="false" returntype="boxcar">
		<cfargument name="apiKey" type="string" required="false" default="#THIS.sApiKey#" />
		<cfargument name="apiSecret" type="string" required="false" default="#THIS.sApiSecret#" />
		<cfset THIS.sApiKey = ARGUMENTS.apiKey />
		<cfset THIS.sApiSecret = ARGUMENTS.apiSecret />
		<cfreturn THIS />
	</cffunction>
	
	
	<cffunction name="logIt" access="public" output="false" returntype="boolean">
		<cfargument name="msg" 		type="string" 	required="true" />
		<cfargument name="method" 	type="string" 	required="true" />
		<!--- For you to implement --->
		<cfreturn TRUE />
	</cffunction>
	
	
	<cffunction name="subscribe" access="public" output="false" returntype="boolean">
		<cfargument name="email" type="string" required="true" />
		
		<cfhttp method="post" url="https://boxcar.io/devices/providers/#THIS.sApiKey#/notifications/subscribe">
			<cfhttpparam name="email" value="#getMd5String(ARGUMENTS.email)#" type="formfield" />
		</cfhttp>
		
		<cfset rc = logIt("subscribe(#ARGUMENTS.email#) returned #CFHTTP.StatusCode#", "subscribe") />

		<cfif Left(CFHTTP.StatusCode, 3) EQ 200>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>
	
	
	<cffunction name="sendNotice" access="public" output="false" returntype="boolean">
		<cfargument name="email" 	type="string" 	required="true" />
		<cfargument name="msg" 		type="string" 	required="true" />
		<cfargument name="from" 	type="string" 	required="false" 	default="" />
		<cfargument name="url" 		type="string" 	required="false" 	default="" />
		<cfargument name="msgId" 	type="numeric" 	required="false" 	default="#getMsgId()#" />
		
		<cfhttp method="post" url="https://boxcar.io/devices/providers/#THIS.sApiKey#/notifications">
			<cfhttpparam name="email" value="#getMd5String(ARGUMENTS.email)#" type="formfield" />
			<cfhttpparam name="notification[from_screen_name]" value="#ARGUMENTS.from#" type="formfield" />
			<cfhttpparam name="notification[message]" value="#ARGUMENTS.msg#" type="formfield" />
			<cfhttpparam name="notification[from_remote_service_id]" value="#ARGUMENTS.msgId#" type="formfield" />
			<cfif Len(ARGUMENTS.url)>
				<cfhttpparam name="notification[source_url]" value="#ARGUMENTS.url#" type="formfield" />
			</cfif>
		</cfhttp>

		<cfset rc = logIt("sendNotice(#ARGUMENTS.email#, #ARGUMENTS.msg#, #ARGUMENTS.from#, #ARGUMENTS.url#, #ARGUMENTS.msgId#) returned #CFHTTP.StatusCode#", "sendNotice") />

		<cfif Left(CFHTTP.StatusCode, 3) EQ 200>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>
	
	
	<cffunction name="broadcast" access="public" output="false" returntype="boolean">
		<cfargument name="msg" 		type="string" 	required="true" />
		<cfargument name="from" 	type="string" 	required="false" 	default="" />
		<cfargument name="url" 		type="string" 	required="false" 	default="" />
		<cfargument name="msgId" 	type="numeric" 	required="false" 	default="#getMsgId()#" />
		
		<cfhttp method="post" url="https://boxcar.io/devices/providers/#THIS.sApiKey#/notifications/broadcast">
			<cfhttpparam name="secret" value="#THIS.sApiSecret#" type="formfield" />
			<cfhttpparam name="notification[from_screen_name]" value="#ARGUMENTS.from#" type="formfield" />
			<cfhttpparam name="notification[message]" value="#ARGUMENTS.msg#" type="formfield" />
			<cfhttpparam name="notification[from_remote_service_id]" value="#ARGUMENTS.msgId#" type="formfield" />
			<cfif Len(ARGUMENTS.url)>
				<cfhttpparam name="notification[source_url]" value="#ARGUMENTS.url#" type="formfield" />
			</cfif>
		</cfhttp>

		<cfset rc = logIt("broadcast(#ARGUMENTS.msg#, #ARGUMENTS.from#, #ARGUMENTS.url#, #ARGUMENTS.msgId#) returned #CFHTTP.StatusCode#", "broadcast") />
		
		<cfif Left(CFHTTP.StatusCode, 3) EQ 200>
			<cfreturn TRUE />
		<cfelse>
			<cfreturn FALSE />
		</cfif>
	</cffunction>
	
	
	<cffunction name="getMd5String" access="private" output="false" returntype="string">
		<cfargument name="str" type="string" required="true" />
		<cfset VARIABLES.sMd5 = LCase(hash(ARGUMENTS.str, "MD5")) />
		<cfset rc = logIt("Returning #VARIABLES.sMd5#", "getMd5String") />
		<cfreturn VARIABLES.sMd5 />
	</cffunction>
	
	<cffunction name="getMsgId" access="private" output="false" returntype="numeric">
		<cfreturn DateFormat(Now(), "yymmdd") & TimeFormat(Now(), "HHmmssl") />
	</cffunction>
</cfcomponent>