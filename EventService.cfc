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
    
    
    <cffunction name="deleteEvent" access="remote" returntype="struct">
        <cfargument name="id" type="numeric" required="true">
    
        <!-- Initialize a struct for the response -->
        <cfset var response = {}>
        
        <!-- Delete the event from the database -->
        <cfquery datasource="CalendarEvent">
            DELETE FROM events WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <!-- Populate the response struct with a success message -->
        <cfset response.message = "Event deleted successfully">
        
        <!-- Return the response struct -->
        <cfreturn response>
    </cffunction>
    
    <cffunction name="updateEventDate" access="remote" returntype="struct">
        <cfargument name="id" type="numeric" required="true">
        <cfargument name="newDate" type="date" required="true">
    
        <!-- Initialize a struct for the response -->
        <cfset var response = {}>
    
        <!-- Update the event's date in the database -->
        <cfquery datasource="CalendarEvent">
            UPDATE events 
            SET event_date = <cfqueryparam value="#arguments.newDate#" cfsqltype="cf_sql_date">
            WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <!-- Populate the response struct with a success message -->
        <cfset response.message = "Event date updated successfully">
        
        <!-- Return the response struct -->
        <cfreturn response>
    </cffunction>
    

    
</cfcomponent>
