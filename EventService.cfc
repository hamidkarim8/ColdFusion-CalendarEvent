<cfcomponent displayname="EventService" output="false">
    
    <cffunction name="retrieveEvents">
        <cftry>
            <cfquery name="getEvent" returntype="query" datasource="CalendarEvent">
                SELECT * FROM events
            </cfquery>
            
            <!---<cfdump var="#getEvent#" label="Event Retrieved" display="true">--->
            
            <cfreturn getEvent>
            <cfcatch>
                <cfoutput>Error: #cfcatch.message#</cfoutput>
                <cfreturn "" />
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="addEvent" access="remote" returntype="struct">
        <cfargument name="name" type="string" required="true">
        <cfargument name="color" type="string" required="true">
    
        <!-- Initialize a struct for the response -->
        <cfset var response = {}>
    
        <!-- Capture the incoming event details -->
        <cfset response.name = arguments.name>
        <cfset response.color = arguments.color>
    
        <!-- Insert the new event -->
        <cfquery datasource="CalendarEvent">
            INSERT INTO events (name, color)
            VALUES (
                <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">, 
                <cfqueryparam value="#arguments.color#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
    
        <!-- Retrieve the ID of the newly inserted event -->
        <cfquery name="qGetEventId" datasource="CalendarEvent">
            SELECT CAST(SCOPE_IDENTITY() AS INT) AS eventId
        </cfquery>
    
        <!-- Populate the response struct with the event ID -->
        <cfset response.eventId = qGetEventId.eventId>
    
        <!-- Return the response struct including debug info -->
        <cfreturn response>
    </cffunction>
    
    

    
</cfcomponent>
