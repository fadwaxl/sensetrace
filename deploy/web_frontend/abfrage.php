<?php
//echo "Time from: " . $_GET['timefrom'] . " Time to: " . $_GET['timeto'] . " Key(s): " . $_GET['key'];  
//echo 	"\nerrorcheck: " . $_GET['errorcheck']." showerror: " . $_GET['showerror'];
//echo 	"\nfullcover: " . $_GET['fullcover'];
//Key in eizelne Elemente zerlegen
 $key = $_GET['key'];
//echo "key: $key<br>";
 $keys = explode("+",$key);
 $sensor="$keys[0]";
  // echo "keys[1]: $keys[1]<br>";
  $ceprules=explode(",",$keys[1]);
  //echo "sensor: $sensor<br>";
   //echo "ceprules[0]: $ceprules[0]<br>";
   //echo 'ceprules.length'. count($ceprules);
 $label="";
$jsontree='[';
 //foreach( $keys as $key){


$datefrom = strtotime($_GET['timefrom']);
$dateto = strtotime($_GET['timeto']);
if ($_GET['resolution']=="1second")
{
	$intervallstring=":1sec";
}
else if ($_GET['resolution']=="1minute")
{
	$intervallstring=":1min";
}
else if ($_GET['resolution']=="15minute")
{
	$intervallstring=":15min";
}
else if ($_GET['resolution']=="1hour")
{
	$intervallstring=":1h";
}
else if ($_GET['resolution']=="1day")
{
	$intervallstring=":1d";
}
else if ($_GET['resolution']=="1month")
{
	$intervallstring=":1m";
}
else if ($_GET['resolution']=="1year")
{
	$intervallstring=":1year";
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
	 $sub_ceprules = explode(":diff",$ceprules[0]);
	 	$cepstring='?rulename dc:clid ?clid. Filter (?rulename!=<'.$sub_ceprules[0].'>';
	}
		else 	if (strpos($ceprules[0],':union') !== false)
	{
	 $sub_ceprules = explode(":union",$ceprules[0]);
	 	$cepstring='?rulename dc:clid ?clid. Filter (?rulename=<'.$sub_ceprules[0].'>';
	}
	$cepstring2='?a <urn:sensor:measure'.$intervallstring.':clid>    ?clid. '; 
}

$n=1;

while ($n<count($ceprules))
{
	
	//When ceprules contains diff !=, else =
	if (strpos($ceprules[n],':diff') !== false)
	{
	 $sub_ceprules = explode(":diff",$ceprules[n]);
	 	$cepstring="$cepstring ?rulename!=<$sub_ceprules[0]>";
	}
		else 	if (strpos($ceprules[n],':union') !== false)
	{
	 $sub_ceprules = explode(":union",$ceprules[n]);
	 	 $cepstring="$cepstring ?rulename=<$sub_ceprules[0]>";
	}
	
$cepstring="$cepstring ?rulename=<$sub_ceprules[0]>";
$n=$n+1;
}

if  ($ceprules[0]!='')
{$cepstring="$cepstring)";
}

$sparql = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
select distinct ?time ?value ?id where
{
<'.$sensor.'> dc:id ?id.
'.
$cepstring.'
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
 $containssecondkey=false; 
 $keys = explode(",",$key); 
 $ceprules =  explode("+",$key); 

$stringposition = strpos ($keys[0], ',' );
$stringposition = strpos ($keys[0], '+' );
$sensor = substr($keys[0],0,$stringposition)  ;
//echo "stringposition: ".$stringposition."\n";
//echo "sensor: ".$sensor."\n";
 $n=1; 
 while($n<sizeof($keys)) 
 { 
	 if (strpos($keys[$n],$sensor) == false) 
		{ 
		 $containssecondkey=true; 
		} 
		 $n++; 
	}


 if ($containssecondkey )
 {
	 echo "You can download only one sensor!";
 }
 else
echo $sparql;
?>
