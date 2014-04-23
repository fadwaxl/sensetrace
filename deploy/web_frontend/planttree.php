<?php

require_once( "sparqllib.php" );
 
$db = sparql_connect( "http://localhost:3030/data/query" );
if( !$db ) { print $db->errno() . ": " . $db->error(). "\n"; exit; }
$db->ns( "foaf","http://xmlns.com/foaf/0.1/" );
$db->ns( "dc","http://purl.org/dc/elements/1.1/" );
$db->ns( "ms","http://measurementg/dc/elements/1.1/" );

if ($_GET['key']=="")
{
	//
$sparql = "SELECT DISTINCT ?url WHERE { <urn:places> dc:places ?url. } order by ?url";
//$sparql = "SELECT ?name ?url WHERE { <urn:places> dc:places ?url. ?url dc:name ?name } ";
}
else
{
$key=$_GET['key'];
$sparql = "SELECT ?url WHERE {<"."$key"."> ?b ?url. FILTER (?b=dc:inst || ?b=dc:sens )}";
}

$result = $db->query( $sparql ); 
if( !$result ) { print $db->errno() . ": " . $db->error(). "\n"; exit; }
 
$fields = $result->field_array( $result );
 
$result = $db->query( $sparql ); 

if( !$result ) { print $db->errno() . ":" . $db->error(). "\n"; exit; }
 
$fields = $result->field_array( $result );

if ($_GET['key']=="")
{
//$jsontree='[{"title":"Selection"}';
$jsontree='[';
while( $row = $result->fetch_array() )
{
	
	//foreach( $fields as $field )
	//{
		$jsontree="$jsontree".'{"title":"'."$row[url]".'","icon":false,"isFolder":true,"isLazy":true,"key":"'."$row[url]".'"},';
	//}
	
}

$jsontree=substr($jsontree, 0, -1);
$jsontree="$jsontree".']';
echo "$jsontree";
}

else
{
$jsontree='[';
$row = $result->fetch_array();
if($row)
{
do
{
	
	
	//foreach( $fields as $field )
	//{
		$jsontree="$jsontree".'{"title":"'."$row[url]".'","icon":false,"isFolder":false,"isLazy":true,"key":"'."$row[url]".'"},';
	//}
	
}while( $row = $result->fetch_array() );

$jsontree=substr($jsontree, 0, -1);
echo "$jsontree".']';
}
}

