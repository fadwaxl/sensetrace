<?php
 require_once( "sparqllib.php" );
$db = sparql_connect( "http://localhost:3030/combined/query" );
 
 //Key in eizelne Elemente zerlegen
 $key = $_GET['key'];
// echo "key: $key<br>";
 $keys = explode("+",$key);
 $sensor="$keys[0]";
  // echo "keys[1]: $keys[1]<br>";
  $ceprules=explode(",",$keys[1]);
 // echo "sensor: $sensor<br>";
   /*  echo "key ".  htmlentities($key)."<br>)";
  echo "keys[1] $keys[1]<br>";
   echo "keys[2] $keys[2]<br>";
   echo "ceprules[0]: $ceprules[0]<br>";
     echo "ceprules[1]: $ceprules[1]<br>";
         echo "ceprules[2]: $ceprules[2]<br>";
             echo "ceprules[3]: $ceprules[3]<br>";
   echo 'ceprules.length'. count($ceprules); */
 $label="";
$jsontree='[';
 //foreach( $keys as $key){

 

if( !$db ) { print $db->errno() . ": " . $db->error(). "\n"; exit; }
$db->ns( "foaf","http://xmlns.com/foaf/0.1/" );
$db->ns( "dc","http://purl.org/dc/elements/1.1/" );
$db->ns( "ms","http://measurement/dc/elements/1.1/" );

$datefrom = strtotime($_GET['timefrom']);
$dateto = strtotime($_GET['timeto']);
if (($dateto-$datefrom)<=600)
{
	$intervallstring=":1sec";
}
else if ((($dateto-$datefrom)>600) and (($dateto-$datefrom)<=6000))
{
	$intervallstring=":1min";
}
else if ((($dateto-$datefrom)>6000) and (($dateto-$datefrom)<=60000))
{
	$intervallstring=":15min";
}
else if ((($dateto-$datefrom)>60000) and (($dateto-$datefrom)<=1200000))
{
	$intervallstring=":1h";
}
else if ((($dateto-$datefrom)>1200000) and (($dateto-$datefrom)<=32832000))
{
	$intervallstring=":1d";
}
else if (($dateto-$datefrom)>32832000) 
{
	$intervallstring=":1m";
}
$corr="";

if($_GET['errorcheck']=="true")
{
$corr="_cor";
}
else
{
	$corr="";
}
/*  echo "sensor2: $sensor<br>"; */
//Create a string to query a clid
if  ($ceprules[0]=='')
{
	$cepstring='';
	$cepstring2='';
	$label='cl:';
}
else{
	//  echo "ceprules[0]: $ceprules[0]<br>";
	//When ceprules contains diff !=, else =
	if (strpos($ceprules[0],':diff') !== false)
	{
	 $sub_ceprules = explode(':diff',$ceprules[0]);
	 	 	$cepstring="?rulename dc:clid ?clid. Filter (?rulename!=<$sub_ceprules[0]>";
	}
		else 	if (strpos($ceprules[0],':union') !== false)
		
	{
				/* echo "<br>found union1<br>"; */
	 $sub_ceprules = explode(':union',$ceprules[0]);
	 /* echo "sub cep: $sub_ceprules[0] <br>"; */
	 	$cepstring="?rulename dc:clid ?clid. Filter (?rulename=<$sub_ceprules[0]>";
	 /* 	 echo "cepstring: $cepstring <br>";
	 	echo "init cepstring: $cepstring";
echo "<br>"; */
	}
	$cepstring2='?a <urn:sensor:measure'.$intervallstring.':clid>    ?clid. '; 
}

$n=1;

while ($n<count($ceprules))
{

/* echo "ceprules[$n]: $ceprules[$n]";
echo "<br>";
echo "<br>"; */
	//When ceprules contains diff !=, else =
	if (strpos($ceprules[$n],':diff') !== false)
	{
		/* echo "<br>found diff<br>"; */
	 $sub_ceprules = explode(':diff',$ceprules[$n]);
		 $cepstring=$cepstring.'&& ?rulename != <'.$sub_ceprules[0].'>';
	}
		else 	if (strpos($ceprules[$n],':union') != false)
	{
		/* echo "<br>found union<br>"; */
	 $sub_ceprules = explode(':union',$ceprules[$n]);
	/*  echo "sub_ceprules[0] $sub_ceprules[0]" ;
	  echo "<br>cepstringv:  $cepstring<br>"; */
	 	 $cepstring=$cepstring.'|| ?rulename = <'.$sub_ceprules[0].'>';
	 	  /* echo "<br>cepstringn:  $cepstring<br>"; */
	}
	
//$cepstring="$cepstring ?rulename=<$sub_ceprules[0]>";
/*  echo "<br>cepstring:  $cepstring<br>"; */
$n=$n+1;
}
 /* echo "sensor3: $sensor<br>"; */

if  ($ceprules[0]!='')
{$cepstring="$cepstring)";
}

$sparql = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
select distinct ?time ?value where
{
<'.$sensor.'> dc:id ?id.
{'.
$cepstring.'}
SERVICE <http://127.0.0.1:3030/d2rq/query> 
{
?a <urn:sensor:measure'.$intervallstring.':value'.$corr.'>  ?value.
?a <urn:sensor:measure'.$intervallstring.':timestamp>  ?time.
?a <urn:sensor:measure'.$intervallstring.':sensorid>    ?id.
'.$cepstring2.' 
  FILTER(?time >= \''.$_GET['timefrom'].'\'^^xsd:dateTime && ?time <= \''.$_GET['timeto'].'\'^^xsd:dateTime ) 
}
}
ORDER BY ASC(?time)
LIMIT 10000
';
 //echo $sensor."<br>";
 //echo  htmlentities($sparql); 
$result = $db->query( $sparql ); 

if( !$result ) { print $db->errno() . ":" . $db->error(). "\n"; exit; }
 
$fields = $result->field_array( $result );

//if ($_GET['key']=="")

//$jsontree='[{"title":"Selection"}';
$jsontree="$jsontree";
$wasinloop=false;
while( $row = $result->fetch_array() )
{
/* echo "n1"; */

	//foreach( $fields as $field )
	//
		//Neu 
		//echo $row['time'];
		//$jsontree="$jsontree".'['.'"'.$row['time'].'",'.substr($row['value'], 0, -2).'],';
		$jsontree="$jsontree".'['.''.(strtotime($row['time'])*1000).','.substr($row['value'], 0, -2).'],';
		//$jsontree="$jsontree".'['.'"'.str_replace("T"," ",$row['time']).'",'.substr($row['value'], 0, -2).'],';
		$wasinloop=true;
//}
}
if ($wasinloop==true)
{
//Komma nach letztem Element entfernen
$jsontree=substr($jsontree, 0, -1);
//Klammer nach letztem Element einfügen

$jsontree="$jsontree".']';
}
else 
{
$jsontree="$jsontree".']';
}
//echo "Test";
$label="$label".'"'.$sensor.'",';
//}

//Letztes Element im Label-String entfernen
//$label=substr($label, 0, -1);

//Komma und Klammer entfernen
//$jsontree=substr($jsontree, 0, -2);
//$jsontree="$jsontree".']],"labels":['.$label.']';
//$jsontree="$jsontree".']],"labels":["labelB","labelA"]';
//echo '"label"'"$jsontree";



//$jsontree="$jsontree".',"tickintervall":"'."$tickintervall".' seconds"}';

//echo "$jsontree";
$classify="";
if  ($ceprules[0]!=''){
$sensor=$sensor.':cl';
$classify='"lines":true,';
}
//{ "label": "urn:stg_1:weather:temperature", "data": [[1999, 3.0], [2000, 3.9], [2001, 2.0], [2002, 1.2], [2003, 1.3], [2004, 2.5], [2005, 2.0], [2006, 3.1], [2007, 2.9], [2008, 0.9]] }
if ($sensor == "urn:stg_1:weather:WindDirection")
{
echo '{ "label": "'.$sensor.'", "data": '.$jsontree.', "yaxis": 1 }';
}
else if ($sensor == "urn:stg_1:weather:WindSpeed")
{
echo '{ "label": "'.$sensor.'", "data": '.$jsontree.', "yaxis": 2  }';
}

else if  ($sensor == "urn:stg_1:weather:radiationfoto")
{
echo '{ "label": "'.$sensor.'", "data": '.$jsontree.', "yaxis": 3  }';
}
else 
{
echo '{ "label": "'.$sensor.'", "data": '.$jsontree.','.$classify.'"yaxis": 4  }';
}
/*echo "{
    \"label\": \"urn:stg_1:weather:temperature\",
    \"data\": [[1999, 3.0], [2000, 3.9], [2001, 2.0], [2002, 1.2], [2003, 1.3], [2004, 2.5], [2005, 2.0], [2006, 3.1], [2007, 2.9], [2008, 0.9]]
}";


if ($key == "urn:stg_1:weather:temperature")
{

echo "{
    \"label\": \"urn:stg_1:weather:temperature\",
    \"data\": [[1999, 3.0], [2000, 3.9], [2001, 2.0], [2002, 1.2], [2003, 1.3], [2004, 2.5], [2005, 2.0], [2006, 3.1], [2007, 2.9], [2008, 0.9]]
}";
}
if ($key == "urn:stg_1:weather:windspeed")
{
echo "{
    \"label\": \"urn:stg_1:weather:windspeed\",
    \"data\": [[1999, 4.4], [2000, 3.7], [2001, 0.8], [2002, 1.6], [2003, 2.5], [2004, 3.6], [2005, 2.9], [2006, 2.8], [2007, 2.0], [2008, 1.1]]
}";	
}*/
//Beispiel-String für mehrere Graphen

/* echo "{
\"data\":[[[\"07/06/2000\",22.0],[\"08/06/2000\",20.0],[\"08/06/2003\",15.0],[\"08/06/2005\",35.0],[\"08/06/2007\",12.0],[\"08/06/2010\",10.0],[\"08/06/2012\",10.0]],[[\"07/06/2000\",21.0],[\"08/06/2000\",19.0],[\"08/06/2003\",14.0],[\"08/06/2005\",34.0],[\"08/06/2007\",11.0],[\"08/06/2010\",9.0],[\"08/06/2012\",9.0]],[[\"07/06/2000\",22.0],[\"08/06/2000\",20.0],[\"08/06/2012\",10.0]]],
\"labels\":[\"labelA\",\"labelB\",\"labelC\"]
}";  
 */


