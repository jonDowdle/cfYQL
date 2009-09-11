<cf_yql format="query">
select * from twitter.user.status where id = 'jdowdle'
limit 10
</cf_yql>

<cfdump var="#cfyql#"><cfabort>

<!---Loop over recent flickr images--->
<cfloop query="cfyql">
	<!---Format of the static urls to flickr images--->
	<cfoutput><img src="http://farm#farm#.static.flickr.com/#server#/#id#_#secret#_s_d.jpg"></cfoutput>
</cfloop>
<cfdump var="#cfyql#" expand="false">

<cf_yql format="query">
select * from rss where url='http://rss.news.yahoo.com/rss/topstories'
limit 5
</cf_yql>

<ul>
<cfloop query="cfyql">
	<li>
	<cfoutput><a href="#link#">#title# &mdash; #Source# &mdash; #pubdate#</a>
	<div>#description#</div>
	</cfoutput>
	</li>
</cfloop>
</ul>

<cfdump var="#cfyql#" expand="false">