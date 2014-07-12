<?php
//echo "Time from: " . $_GET['timefrom'] . " Time to: " . $_GET['timeto'] . " Key(s): " . $_GET['key'];

//echo 	"\nerrorcheck: " . $_GET['errorcheck']." showerror: " . $_GET['showerror'];

//echo 	"\nfullcover: " . $_GET['fullcover'];

//Key in eizelne Elemente zerlegen
$key = $_GET['key'];
//echo "key: $key \n";
$keys = explode(",", $key);
//At first find sensors and write to array
$n = 0;
$m = 0;
$j = 0;
while ($n < count($keys)) {
    //When ceprules contains + !=, else =
    
    if (strpos($keys[$n], 'classify') == false) {
        $sensor[$m] = $keys[$n];
        $m = $m + 1;
    }
    else {
        //key can have the from sensor+clid1
        
        //Remove sensor +
        
        //If there is no +, just copy
        
        if (strpos($keys[$n], '+') != false) {
            $str_with_cl = substr($keys[$n], strpos($keys[$n], "+") + 1);
            $ceprules_tmp = explode("+", $str_with_cl);
            $ceprules[$j] = $ceprules_tmp[0];
        }
        else {
            $ceprules[$j] = $keys[$n];
        }
        $j = $j + 1;
    }
    $n = $n + 1;
}

if (count($sensor) > 1) {
    echo "You can download only one sensor!";
}
else {
    /*echo "sensor[0]:$sensor[0]\n";
    
    echo "sensor[1]:$sensor[1].\n";
    //echo "keys[1]: $keys[1]<br>";
    //  echo "keys[2]: $keys[2]<br>";
    
    //keys[1] contains string sensor+clid1+clid2, so delete sensor
    //$keys[1]= substr($keys[1],strpos($keys[1],"+"));
    //$ceprules=explode("+",$keys[1]);
    //echo "keys[1]: $keys[1]<br>";
    echo "ceprules[0]: $ceprules[0]\n";
    echo "ceprules[1]: $ceprules[1]\n";
    //echo "sensor: $sensor<br>";
    //echo "ceprules[0]: $ceprules[0]<br>";
    //echo 'ceprules.length'. count($ceprules);*/
    $label = "";
    $jsontree = '[';
    //foreach( $keys as $key){
    $datefrom = strtotime($_GET['timefrom']);
    $dateto = strtotime($_GET['timeto']);
    
    if ($_GET['resolution'] == "1second") {
        $intervallstring = ":1sec";
    }
    else 
    if ($_GET['resolution'] == "1minute") {
        $intervallstring = ":1min";
    }
    else 
    if ($_GET['resolution'] == "15minute") {
        $intervallstring = ":15min";
    }
    else 
    if ($_GET['resolution'] == "1hour") {
        $intervallstring = ":1h";
    }
    else 
    if ($_GET['resolution'] == "1day") {
        $intervallstring = ":1d";
    }
    else 
    if ($_GET['resolution'] == "1month") {
        $intervallstring = ":1m";
    }
    else 
    if ($_GET['resolution'] == "1year") {
        $intervallstring = ":1year";
    }
    $corr = "";
    
    if ($_GET['errorcheck'] == "true") {
        $corr = "_cor";
    }
    else {
        $corr = "";
    }
    //Create a string to query a clid
    
    if (count($ceprules) == 0) {
        $cepstring = '';
        $cepstring2 = '';
        $label = 'cl:';
    }
    else {
        //  echo "ceprules[0]: $ceprules[0]<br>";
        
        //When ceprules contains diff !=, else =
        
        if (strpos($ceprules[0], ':diff') !== false) {
            $sub_ceprules = explode(":diff", $ceprules[0]);
            $cepstring = '?rulename dc:clid ?clid. Filter (?rulename!=<' . $sub_ceprules[0] . '>';
        }
        else 
        if (strpos($ceprules[0], ':union') !== false) {
            $sub_ceprules = explode(":union", $ceprules[0]);
            $cepstring = '?rulename dc:clid ?clid. Filter (?rulename=<' . $sub_ceprules[0] . '>';
        }
        $cepstring2 = '?a <urn:sensor:measure' . $intervallstring . ':clid>    ?clid. ';
    }
    $n = 1;
    while ($n < count($ceprules)) {
        //When ceprules contains diff !=, else =
        
        if (strpos($ceprules[$n], ':diff') !== false) {
            $sub_ceprules = explode(":diff", $ceprules[$n]);
            $cepstring = $cepstring . '&& ?rulename!=<' . $sub_ceprules[0] . '>';
        }
        else 
        if (strpos($ceprules[$n], ':union') !== false) {
            $sub_ceprules = explode(":union", $ceprules[$n]);
            $cepstring = $cepstring . '|| ?rulename=<' . $sub_ceprules[0] . '>';
        }
        //$cepstring="$cepstring ?rulename=<$sub_ceprules[0]>";
        $n = $n + 1;
    }
    
    if (count($ceprules) > 0) {
        $cepstring = "$cepstring)";
    }
    $sparql = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
select distinct ?time ?value ?id where
{{
<' . $sensor[0] . '> dc:id ?id.
' . $cepstring . '}
SERVICE <http://127.0.0.1:3030/d2rq/query> 
{
?a <urn:sensor:measure' . $intervallstring . ':value' . $corr . '>  ?value.
?a <urn:sensor:measure' . $intervallstring . ':timestamp>  ?time.
?a <urn:sensor:measure' . $intervallstring . ':sensorid>    ?id.
' . $cepstring2 . ' 
  FILTER(?time >= \'' . $_GET['timefrom'] . '\'^^xsd:dateTime && ?time <= \'' . $_GET['timeto'] . '\'^^xsd:dateTime ) 
}
}
ORDER BY ASC(?time)
';
    echo $sparql;
}
?>
