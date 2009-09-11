<cfparam name="attributes.format" default="xml">
<cfparam name="attributes.name" default="cfyql">

<cfif thisTag.ExecutionMode eq 'end'>
	<cfset caller[attributes.name] = processContent( yql = trim(thisTag.GeneratedContent), args = Duplicate(attributes) ) />
	<cfset thisTag.generatedContent = ''>
</cfif>

<cffunction name="processContent" access="private" output="false" returntype="any" >
	<cfargument name="yql" default="">
	<cfargument name="args" default="" />
	
	<cfset var yqlClean = ''/>
	<cfset var yqlResult = '' />
	<cfset var qYqlResult = queryNew('') />
	<cfset var results = '' />
	<cfset var xmlYql = '' />
	<cfset var attributes = Duplicate(arguments.args) />
	<cfset var iterator = '' />
	
	<cfset yqlClean = encodeYql(arguments.yql) />
	
	<cfhttp url="http://query.yahooapis.com/v1/public/yql?q=#yqlClean#&env=http%3A%2F%2Fdatatables.org%2Falltables.env&format=#attributes.format#" method="GET" />	
	
	<cfset xmlYql = xmlParse(cfhttp.filecontent) />
	
	<cfswitch expression="#attributes.format#">
		<cfcase value="query">
			<cfset results = xmlYql.query.results.XmlChildren />
			<cfif ArrayLen(results[1].XmlChildren) eq 0>
			<!---If values are stored in attributes--->
				<cfset attributes = results[1].XmlAttributes />
				<!---Add columns--->
				<cfloop collection="#attributes#" item='attribute'>	
					<cfset colName= attribute />
					<cfif not qYqlResult.columnList contains colName>
						<cfset queryAddColumn(qYqlResult,'#colName#', 'varchar',[] ) /> 
					</cfif>
				</cfloop>
				
				<cfset iterator = results.Iterator() />
				<cfloop condition=#iterator.hasNext()#>
					<cfset result = iterator.next() />
					<cfset queryAddRow(qYqlResult) />
					<cfdump var="#qYqlResult#">						
					<cfloop collection="#result.XmlAttributes#" item="i">
						<cfset querySetCell(qYqlResult, i, result.XmlAttributes[i]) />
					</cfloop>
					<cfdump var="#qYqlResult#">
				</cfloop>
			<cfelse>
			<!---If values are stored in child nodes--->
				<cfset iterator = results[1].XmlChildren.Iterator() />
				<cfloop condition = #iterator.hasNext()# >	
					<cfset colName= iterator.Next().XmlName />
					<cfif not qYqlResult.columnList contains colName>
						<cfset queryAddColumn(qYqlResult,'#replace(colName,':','_','all')#', 'varchar',[] ) /> 
					</cfif>
				</cfloop>
				
				<cfset iterator = results.Iterator() />
				
				<cfloop condition=#iterator.hasNext()#>
					<cfset result = iterator.next() />
					<cfset queryAddRow(qYqlResult) />
					
					<cfloop array="#result.XmlChildren#" index="i">
						<cfset querySetCell(qYqlResult, replace(i.XmlName,':','_','all'), i.XmlText) />
					</cfloop>
				</cfloop>
			</cfif>
			
			<cfset yqlResult = qYqlResult />		
		</cfcase>
		<cfdefaultcase>
			<cfset yqlResult = xmlYql />
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn yqlResult />	
</cffunction>

<cffunction name="encodeYql" access="private" output="false" returntype="String" >
	<cfargument name="dirty" default="">
	<cfset var clean = '' />
	
	<cfset clean = replace(arguments.dirty, ' ', '%20', 'all') />
	
	<cfreturn clean />
</cffunction>