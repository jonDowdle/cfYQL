<cfif thisTag.ExecutionMode eq 'end'>
	<cfset processContent( trim(thisTag.GeneratedContent)) />
</cfif>

<cffunction name="processContent" access="private" output="false" returntype="String" >
	<cfargument name="inYql" default="">
	<cfset var yql = ''/>
	<cfset var qYqlResult = queryNew('') />
	<cfset var results = '' />
	<cfset var xmlYql = '' />
	<cfset var iterator = '' />
	
	<cfset yql = encodeYql(arguments.inYql) />
	
	<cfhttp url="http://query.yahooapis.com/v1/public/yql?q=#yql#&env=http%3A%2F%2Fdatatables.org%2Falltables.env" method="GET" />	
	
	<cfset xmlYql = xmlParse(cfhttp.filecontent) />
	
	<cfset results = xmlYql.query.results.XmlChildren />
	
	<cfif qYqlResult.recordcount eq 0 AND qYqlResult.columnlist eq "" >
		<cfset iterator = results[1].XmlChildren.Iterator() />
		<cfloop condition = #iterator.hasNext()# >	
			<cfset colName= iterator.Next().XmlName />
			<cfif not qYqlResult.columnList contains colName>
				<cfset queryAddColumn(qYqlResult,'#colName#', 'varchar',[] ) /> 
			</cfif>
		</cfloop>
	</cfif>
	
	<cfset iterator = results.Iterator() />
	
	<cfloop condition=#iterator.hasNext()#>
		<cfset result = iterator.next() />
		<cfset queryAddRow(qYqlResult) />
		
		<cfloop array="#result.XmlChildren#" index="i">
			<cfset querySetCell(qYqlResult, i.XmlName, i.XmlText) />
		</cfloop>
	</cfloop>
	
	<cfdump var="#qYqlResult#">
	<cfdump var="#xmlYql#">
	<cfabort>
	
</cffunction>

<cffunction name="encodeYql" access="private" output="false" returntype="String" >
	<cfargument name="dirty" default="">
	<cfset var clean = '' />
	
	<cfset clean = replace(arguments.dirty, ' ', '%20', 'all') />
	
	<cfreturn clean />
</cffunction>