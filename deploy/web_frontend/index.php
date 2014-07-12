<?php include ('auth/auth.php'); ?>
<!DOCTYPE html>

<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <!-- Le styles -->
    <link href="assets/css/bootstrap.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" media="screen"
     href="assets/css/bootstrap-datetimepicker.min.css">
   <link rel="stylesheet" type="text/css" href="assets/css/jquery.jqplot.css" />
   
        
   
	<style>
	
    body {
       
    }
	#target {
  margin: 2em;
	}
.demo-container {
	box-sizing: border-box;
	width: 100%;
	height: 450px;
	padding: 20px 15px 15px 15px;
	margin: 15px auto 30px auto;
	border: 1px solid #ddd;
	background: #fff;
	background: linear-gradient(#f6f6f6 0, #fff 50px);
	background: -o-linear-gradient(#f6f6f6 0, #fff 50px);
	background: -ms-linear-gradient(#f6f6f6 0, #fff 50px);
	background: -moz-linear-gradient(#f6f6f6 0, #fff 50px);
	background: -webkit-linear-gradient(#f6f6f6 0, #fff 50px);
	box-shadow: 0 3px 10px rgba(0,0,0,0.15);
	-o-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
	-ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
	-moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
	-webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
}

.demo-placeholder {
	width: 100%;
	height: 100%;
	font-size: 14px;
	line-height: 1.2em;
}

	</style>
    
    <link href="assets/css/bootstrap-responsive.css" rel="stylesheet">
    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js">
      </script>
    <![endif]-->
    <!-- Le fav and touch icons -->
    <link rel="shortcut icon" href="assets/ico/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="assets/ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="assets/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="assets/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="assets/ico/apple-touch-icon-57-precomposed.png">
    <style>
    </style>
 <!-- Include the required JavaScript libraries: -->
    <script src='jquery/jquery.min.js' type="text/javascript"></script>
    <script src="assets/js/bootstrap.js"></script>
    
    <script src='jquery/jquery-ui.custom.js' type="text/javascript"></script>
    <script src='jquery/jquery.cookie.js' type="text/javascript"></script>
    
    <link rel='stylesheet' type='text/css' href='src/skin-vista/ui.dynatree.css'>
    <script src='src/jquery.dynatree.js' type="text/javascript"></script>

    
<script src="assets/js/bootstrap-datetimepicker.min.js"></script>
<script src="assets/js/knockout-2.2.1.js"></script>
<!--[if lt IE 9]><script language="javascript" type="text/javascript" src="assets/js/excanvas.js"></script><![endif]-->

<script type="text/javascript" src="assets/js/moment.min.js"></script>
<script language="javascript" type="text/javascript" src="assets/js/jquery.flot.min.js"></script>
<script language="javascript" type="text/javascript" src="assets/js/jquery.flot.time.min.js"></script>
<script language="javascript" type="text/javascript" src="assets/js/jquery.flot.selection.min.js"></script>
<script language="javascript" type="text/javascript" src="assets/js/jquery.flot.resize.min.js"></script>

<script type="text/javascript">
$(function() {
	var placeholder = $("#placeholder");
	
		// The plugin includes a jQuery plugin for adding resize events to any
		// element.  Add a callback so we can display the placeholder size.

});
</script>

<script type="text/javascript">
//SPARQL in Textarea schreiben
sparql = function(timeto, timefrom, errorcheck, showerror, fullcover, resolution, key1){
	  $.ajax({
      // have to use synchronous here, else the function 
      // will return before the data is fetched
	  async: false,
	  type:"GET",
	   dataType:"text",
 		url: "abfrage.php",
      
	  data:{timefrom:timefrom,
 			timeto:timeto,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
			resolution:resolution,
			showerror:showerror,
			fullcover:fullcover,
			key: key1},
          success: function(data) {
		  sparql_string=data;
		  $("#sql").val(data);
		 },
	   error: function (xhr, ajaxOptions, thrownError){
                alert(ajaxOptions);
            }   
    });
		 return {
        sparql_string: sparql_string
    };  
    }
</script>

<script type="text/javascript">
//Filter löschen mit entf Taste
$(document).keyup(function (e) {
    if (e.keyCode == 46) {
	parentnode=deleteNode.getParent();
	key_label=parentnode.data.key;
	key1=parentnode.data.key;
	parent=parentnode;
	delKey=deleteNode.data.key;
      deleteNode.remove();
	  //Prüfen ob Parent-Node selected --> dann Graph neu zeichnen
	
	   if(parentnode.isSelected()) 
			{ //Graph neu zeichnen
			 // alten Key mit Filter löschen!
						
				child = [];
					
					 
						var key_label = key_label + ":cl"; 
						
							for (var i = 0; i < data.length; i++) {
								
							var str = key_array[i];
							//var res = str.split("+");
							console.log('str:', str);
							console.log('key:', delKey);
							if (str.match(delKey))
								 // aus dem key_array[i] den Filter entfernen
								  {	 console.log('countChild:', parent.countChildren());
										if (parent.countChildren() == 0)
										{
												key_array.splice(i,1);
												key=key1;
												   
										}
										for (var j = 0; j < parent.countChildren(); j++) {
											key_array[i]=key1+"+"+parent.getChildren()[j].data.key;
											key=key1+"+"+parent.getChildren()[j].data.key;
											console.log('children:', parent.getChildren()[j].data.key);
										}		
								  }
								    if (data[i].label === key_label)
								  {
									  
								  console.log("drin");
								  data.splice(i,1);
								   data2.splice(i,1);
										
								  }
								 
								 
								}
	 
							
  
			console.log('KeyArray:', key_array);
			console.log('data:', data);
			console.log('data2:', data2);
			console.log(key);
										
		
			$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
									
										timeto2=$('#timeto').val();
									 timeto2=timeto2.replace(/ /g,"T");
									 timefrom2=$('#timefrom').val();
									 timefrom2=timefrom2.replace(/ /g,"T");
       
							key1=key_array.join(', '); 
	 
							  //SPARQL string in Textarea schreiben
							  //sparql(timeto, timefrom, errorcheck, showerror, resolution, key1);
							WerteAktualisieren(timeto, timefrom);	 

						n=1;
						if (parent.countChildren() > 0)
										{
						while (n <= 2) { 
							if (n==1)  
							{
								console.log("Ajax!");
							  //Graph zeichnen
									function onDataReceived(series) {

										// Extract the first coordinate pair; jQuery has parsed it, so
										// the data is now just an ordinary JavaScript object

										//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";

										// Push the new data onto our existing data array

									
											data.push(series);
										
										
									
						//richtiger Plot
										plot=$.plot("#placeholder", data, options);
						n=n+1;
									}	
								

											$.ajax({
												url: "GetDataPoints.php",
												type: "GET",
												dataType: "json",
												async: false,
												data:{timefrom:timefrom,
											timeto:timeto,
										  //timefrom:"2012-01-06T08:00:00",
											//timeto:"2012-01-06T09:30:00",
											errorcheck:errorcheck,
												showerror:showerror,
												fullcover:fullcover,
											key: key},
												success: onDataReceived,
												//Keine Sensor Daten vorhanden
												error: function ()
												{
													n=n+1;
													key_array.pop();
												
												}
											});
										}	
										
							if (n==2) {
								//Overview zeichnen
							
										function onDataReceived2(series) {

										// Extract the first coordinate pair; jQuery has parsed it, so
										// the data is now just an ordinary JavaScript object

										//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
									

										// Push the new data onto our existing data array

											data2.push(series);
											
										
										
									
						//overview Plot
								

																$.plot("#overview", data2, options2);
										n=n+1;
											}	
										
											$.ajax({
												url: "GetDataPoints.php",
												type: "GET",
												dataType: "json",
												async: false,
												data:{timefrom:timefrom2,
											timeto:timeto2,
										  //timefrom:"2012-01-06T08:00:00",
											//timeto:"2012-01-06T09:30:00",
											errorcheck:errorcheck,
												showerror:showerror,
												fullcover:fullcover,
											key: key},
												success: onDataReceived2,
												//Keine Sensor Daten vorhanden
												error: function ()
												{
												n=n+1;
												console.log(n);
												}
											});
										}
			
								}
							}				
			}
		}	
});
</script>



<script type="text/javascript">
//WERTE aus dem Formular auslesen, formatieren und an abfrage.php / ins Textfeld schreiben übergeben
WerteAktualisieren = function(timeto, timefrom){
	 // Zeitwerte formatieren
	timeto=timeto;
	timefrom=timefrom;
		 // Data correction auslesen
		if ($('#datacorrection').attr('checked')){ 
        errorcheck=true;
    }
	else
	{
		errorcheck=false;
	}
	console.log(errorcheck);
	//resolution auslesen
	resolution=$('#resolution').val();
	
	//show errordata auslesen
	
	if ($('#showerrordata').attr('checked')){ 
        showerror=true;
    }
	else
	{
		showerror=false;
	}
	
		//show fullcover auslesen
	
	if ($('#fullcover').attr('checked')){ 
        fullcover=true;
    }
	else
	{
		fullcover=false;
	}
	
	  //SPARQL string in Textarea schreiben
	  sparql(timeto, timefrom, errorcheck, showerror, fullcover, resolution, key1);
	//WerteAktualisieren(timeto, timefrom);	 
	
	  return
	  {timeto=timeto;
	timefrom=timefrom;
	}
    }
</script>



<script type="text/javascript">

  $(function()  
  {
	
    $('#datetimepicker1').datetimepicker({
      language: 'en'
    });
	 $('#datetimepicker2').datetimepicker({
      language: 'en'
    });
	timeto=$('#timeto').val();
		 timeto=timeto.replace(/ /g,"T");
		 timefrom=$('#timefrom').val();
		 timefrom=timefrom.replace(/ /g,"T");
		 
	  });
	  </script>
    
<script type="text/javascript"> 
//abfrage.php aufrufen wenn resolution geändert wird
$(function()  
  {
 $('#resolution').change(function() {
  
		WerteAktualisieren(timeto, timefrom);	  
 }); 
}); 
</script>
   
<script type="text/javascript"> 
//Graph updaten wenn Show Data Error geändert wird 
 $(function()  
  {
		$("#showerrordata").change(function() {	  
		if (this.checked) {
		$("#datacorrection").attr('checked', false);

		$("#datacorrection").attr("disabled", true);
		}
		else
		{
		$("#datacorrection").attr("disabled", false);
		}
		 //Graph leeren
 	data = [];
		data2 = [];
	$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
		
		WerteAktualisieren(timeto, timefrom);
		
		  //Graph zeichnen
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

			data.push(series);
				data2.push(series);
				

								// Overview Plot
			$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {


	$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
			errorcheck:errorcheck,
			showerror:showerror,
			fullcover:fullcover,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			key: key_array[i]},
				success: onDataReceived
			});
}
 }); 
}); 
</script>	
<script type="text/javascript"> 
//Graph updaten wenn clid full cover geändert wird 
 $(function()  
  {
		$("#fullcover").change(function() {	  
		
		 //Graph leeren
 	data = [];
		data2 = [];
	$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
		
		WerteAktualisieren(timeto, timefrom);
		
		  //Graph zeichnen
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

			data.push(series);
				data2.push(series);
				

								// Overview Plot
			$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {


	$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
			errorcheck:errorcheck,
			showerror:showerror,
			fullcover:fullcover,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			key: key_array[i]},
				success: onDataReceived
			});
}
 }); 
}); 
</script>	
      <script type="text/javascript"> 
	//Graph updaten wenn Data correction geändert wird
	 $(function()  
  {
$("#datacorrection").change(function() {
   //Graph leeren
	
	 //Graph leeren
 	data = [];
		data2 = [];
	$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
		
		WerteAktualisieren(timeto, timefrom);
	  
	  
   //Graph zeichnen
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

			data.push(series);
				data2.push(series);
				

								// Overview Plot
			$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {


	$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
			errorcheck:errorcheck,
			showerror:showerror,
			fullcover:fullcover,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			key: key_array[i]},
				success: onDataReceived
			});
}

	
 }); 


	//Graph updaten wenn Datum TimeFom geändert wird

	 $('#datetimepicker1').datetimepicker().on('changeDate', function(e) {
   //Graph leeren
 	data = [];
		data2 = [];
	$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
	
	
		    // Zeitwerte formatieren
	 	timeto=$('#timeto').val();
		 timeto=timeto.replace(/ /g,"T");
		 timefrom=$('#timefrom').val();
		 timefrom=timefrom.replace(/ /g,"T");
		 WerteAktualisieren(timeto, timefrom);
	
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array
				data.push(series);
				data2.push(series);
				
			$.plot("#placeholder", data, options);
								// Overview Plot
			$.plot("#overview", data2, options2);
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {


	$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
			showerror:showerror,
			fullcover:fullcover,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
			key: key_array[i]},
				success: onDataReceived
			});
}

	
 }); 

	//Graph updaten wenn Datum TimeTo geändert wird

	 $('#datetimepicker2').datetimepicker().on('changeDate', function(e) {
   //Graph leeren
   
  	data = [];
		data2 = [];
	$.plot("#placeholder", data, options);
	$.plot("#overview", data2, options2);
		    // Zeitwerte formatieren
	 	timeto=$('#timeto').val();
		 timeto=timeto.replace(/ /g,"T");
		 timefrom=$('#timefrom').val();
		 timefrom=timefrom.replace(/ /g,"T");
		 WerteAktualisieren(timeto, timefrom);
	
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array
				data.push(series);
				data2.push(series);
			//richtiger Plot
			$.plot("#placeholder", data, options);
			// Overview Plot
			$.plot("#overview", data2, options2);
			
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {


	$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key_array[i]},
				success: onDataReceived
			});
}

		 
	});	 

    <!-- Add code to initialize the tree when the document is loaded: -->

//Graphoptionen
 options = {
			lines: {
				show: true
			},
			points: {
				show: true
			},
			legend: {
				position: "nw"
			},
			  xaxes: [ {  mode: "time", timezone: "browser" } ],
    yaxes: [  {
                tickFormatter: function (val, axis) {
				
                    return val.toFixed(2) + "°C";
                }
            }, 
			{tickFormatter: function (val, axis) {
                    return val.toFixed(2) + "m/s";
                }, position:"right"},
{
                tickFormatter: function (val, axis) {
                    return val.toFixed(2) + "W/m²";
                }
            }, 				],
	
	selection: {
				mode: "x"
			}
		};
		options2 = {
	
			series: {
				lines: {
					show: true,
					lineWidth: 1
				},
				shadowSize: 0
			},
			legend: {
			show: 0,
			},
			  xaxes: [ { mode: "time", timezone: "browser" } ],
    yaxes: [  {ticks: []}, {ticks: []},{ticks: []}	],
	
	selection: {
				mode: "x"
			}
		};
	
	//Zooming	
var placeholder = $("#placeholder");

		placeholder.bind("plotselected", function (event, ranges) {

	//$("#selection").text(ranges.xaxis.from.toFixed(1) + " to " + ranges.xaxis.to.toFixed(1));
   //Graph leeren
		data = [];
		$.plot("#placeholder", data, options);
	
		   //Graph zeichnen
		   
	 timefrom=Math.floor(ranges.xaxis.from.toFixed(1));
	 

		 timeto=Math.floor(ranges.xaxis.to.toFixed(1));
		 
		 timeto = moment(timeto).format("YYYY-MM-DDTHH:mm:ss");
		timefrom = moment(timefrom).format("YYYY-MM-DDTHH:mm:ss");
	
		 WerteAktualisieren(timeto, timefrom);
		 
	 function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

				
				data.push(series);
				

				$.plot("#placeholder", data, options);
				console.log(series);
			}
	
		 
		 for (var i = 0; i < key_array.length; i++) {
 

	$.ajax({
	
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
			showerror:showerror,
			fullcover:fullcover,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
			key: key_array[i]},
				success: onDataReceived
			});
			
}

	
 
		 
			// don't fire event on the overview to prevent eternal loop

			//overview.setSelection(ranges, true); 
	
	});				//Zoom ende
			$("#overview").bind("plotselected", function (event, ranges) {
			plot.setSelection(ranges);
		});
		
		data = [];
		key_array = [];
		data2 = [];
		child = [];
		
	
		$.plot("#placeholder", data, options);
	
		
		// Fetch one series, adding to what we already have

		alreadyFetched = {};

    // --- Initialize  trees
    $("#tree").dynatree({
     checkbox: true,
	 icon: false,
	 selectMode: 2,
	

	 onSelect: function(select,  node) {
	 // Get a list of all selected nodes, and convert to a key array:
         selKeys = $.map(node.tree.getSelectedNodes(), function(node){
          return node.data.key;
		  });
		
			
		anzahlKeys=selKeys.length;
		child = [];
		key1=selKeys.join(", ");
		 key=node.data.key;
		 
		
		
		key_label=key;
		  if( ! select ) //Wenn Node deaktiviert wird
              {  
			  if (node.hasChildren()==true)
			  {console.log("Child True");
			  //Get all Children
				node.visit(function(n){
					child.push(n.data.key);
				});
				//Children an Key hängen
				key_label_child = key + ":cl";
				key_child=key+"+"+child.toString();
				for (var i = 0; i < data.length; i++) {
var str = key_array[i];
			
 
  if (str == key_child)
  {
 
  key_array.splice(i,1);
  }
  
   if (data[i].label == key_label_child)
  {
  
  data.splice(i,1);
   data2.splice(i,1);
  }
  
}
			}	
			
			console.log(key);
			
for (var i = 0; i < data.length; i++) {
var str = key_array[i];
			
  if (str == key)
  {
 
  key_array.splice(i,1);
  }
  
   if (data[i].label == key_label)
  {
  
  data.splice(i,1);
   data2.splice(i,1);
  }
  
  
}



console.log('KeyArray:', key_array);
				console.log('data:', data);
				console.log('data2:', data2);

			 
	console.log(alreadyFetched);
			console.log(key_array);
		
//data.pop(); //letztes Element aus Array entfernen
    //alert( country );
    //data.push( data[0] );

	
	 key1=key_array.join(', '); 
//SPARQL string in Textarea schreiben
	  //sparql(timeto, timefrom, errorcheck, showerror, resolution, key1);
	 WerteAktualisieren(timeto, timefrom);	 
	  
$.plot("#placeholder", data, options);
$.plot("#overview", data2, options2);
			 }
			 
			 
			 else //Wenn Node aktiviert wird
			 {
			 key_array.push(key);
			 //Get all Children
			 var k = 2;
			 console.log("k=2");
			 
			  if (node.hasChildren()==true)
			  { console.log("Child True");
			 
				node.visit(function(n){
					child.push(n.data.key);
					
				});
				//Children an Key hängen
				 var k = 4;
				key_child=key+"+"+child.toString(); 
				key_array.push(key_child);
				}
			 console.log("k1:");
console.log(k);

			//SQL Button aktivieren bei einem node bzw deaktivieren wenn mehrere nodes ausgewählt sind
			 $('#download').attr("disabled",false);
			
			
			 console.log(key);
			 console.log("key_array", key_array);
		WerteAktualisieren(timeto, timefrom);
			timeto2=$('#timeto').val();
		 timeto2=timeto2.replace(/ /g,"T");
		 timefrom2=$('#timefrom').val();
		 timefrom2=timefrom2.replace(/ /g,"T");
       
        // Get a list of all selected TOP nodes
        var selRootNodes = node.tree.getSelectedNodes(true);
        // ... and convert to a key array:
        var selRootKeys = $.map(selRootNodes, function(node){
          return node.data.key;
        });
       
	key1=key_array.join(', '); 
	  //SPARQL string in Textarea schreiben
	  //sparql(timeto, timefrom, errorcheck, showerror, resolution, key1);
	WerteAktualisieren(timeto, timefrom);	 

n=1;
 console.log("k2:");
console.log(k);
if (k == 4)
{
while (n <= 4) {

	if (n==1)  
	{
	  //Graph zeichnen
			function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";

				// Push the new data onto our existing data array

			
					data.push(series);
				
				
			
//richtiger Plot
				plot=$.plot("#placeholder", data, options);
n=n+1; 
console.log(n); 
			}	
		

			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key},
				success: onDataReceived,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
					n=n+1;
					key_array.pop();
				
				}
			});
		}	
		
		if (n==2) {
		//Overview zeichnen
	
				function onDataReceived2(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

					data2.push(series);
					
				
				
			
//overview Plot
		

		$.plot("#overview", data2, options2);
		n=n+1;
		console.log(n); 
			}	
		
			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom2,
 			timeto:timeto2,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key},
				success: onDataReceived2,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
				n=n+1;
				console.log(n);
				}
			});
		}
		if (n==3) {
		//Overview zeichnen
	
				function onDataReceived2(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

					data2.push(series);
					
				
				
			
//overview Plot
		

		$.plot("#overview", data2, options2);
		n=n+1;
		console.log(n); 
			}	
		
			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom2,
 			timeto:timeto2,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key_child},
				success: onDataReceived2,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
				n=n+1;
				console.log(n);
				}
			});
		}	
	if (n==4)  
	{
	  //Graph zeichnen
			function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";

				// Push the new data onto our existing data array

			
					data.push(series);
				
				
			
//richtiger Plot
				plot=$.plot("#placeholder", data, options);
n=n+1;
console.log(n); 
			}	
		

			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key_child},
				success: onDataReceived,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
					n=n+1;
					key_array.pop();
				
				}
			});
		}		
}
}
if ( k == 2)
{
while (n <= 2) {

	if (n==1)  
	{
	  //Graph zeichnen
			function onDataReceived(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";

				// Push the new data onto our existing data array

			
					data.push(series);
				
				
			
//richtiger Plot
				plot=$.plot("#placeholder", data, options);
n=n+1; 
console.log(n); 
			}	
		

			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom,
 			timeto:timeto,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key},
				success: onDataReceived,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
					n=n+1;
					key_array.pop();
				
				}
			});
		}	
		
		if (n==2) {
		//Overview zeichnen
	
				function onDataReceived2(series) {

				// Extract the first coordinate pair; jQuery has parsed it, so
				// the data is now just an ordinary JavaScript object

				//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
			

				// Push the new data onto our existing data array

					data2.push(series);
					
				
				
			
//overview Plot
		

		$.plot("#overview", data2, options2);
		n=n+1;
		console.log(n); 
			}	
		
			$.ajax({
				url: "GetDataPoints.php",
				type: "GET",
				dataType: "json",
				async: false,
				data:{timefrom:timefrom2,
 			timeto:timeto2,
		  //timefrom:"2012-01-06T08:00:00",
 			//timeto:"2012-01-06T09:30:00",
			errorcheck:errorcheck,
				showerror:showerror,
				fullcover:fullcover,
			key: key},
				success: onDataReceived2,
				//Keine Sensor Daten vorhanden
				error: function ()
				{
				n=n+1;
				console.log(n);
				}
			});
		}
		
		
}
}

}
		
 //SQL Button aktivieren bei einem node bzw deaktivieren wenn mehrere nodes oder keiner ausgewählt sind
			if (anzahlKeys==1)
			{
			 $('#download').removeAttr("disabled");
			 console.log("hello1");
			 }
			 else
			 {
			 console.log("hello2");
			 $('#download').attr("disabled", "disabled");
			 }
			 
      },
	  
	  fx: { height: "toggle", duration: 200 },
	
        initAjax: {
            url: "planttree.php"
        
             },
      // .. but here we use a local file instead:
	  
     // initAjax: {
		  
       // url: "sample-data3.json"
		
      //  },

      onActivate: function(node) {
        //console.log(node.data.key);
		
		
      },
  onFocus: function(node) {
	//Ermitteln ob Node ein Filter ist
		console.log(data);
		console.log(data2);
		var res =[];
		var str= " ";
		var str = node.data.key;
		var res = str.split(":");
		deleteNode = " ";
		console.log(str);
		console.log(res);
		found = $.inArray('classify', res);
		console.log(found);
		if (found === 1)//Wenn Node = Filter dann löschen erlauben
			{ console.log("löschbar");
				
						  deleteNode=node;
						}
			
    },
      onLazyRead: function(node){
        // In real life we would call something like this:
		//Get Child Nodes
		
              node.appendAjax({
                 url: "planttree.php",
                data: {key: node.data.key,
                       mode: "funnyMode"
                         }
             });
        // .. but here we use a local file instead:
		
      
      },
	  dnd: {
      autoExpandMS: 1000,
      preventVoidMoves: true, // Prevent dropping nodes 'before self', etc.
      onDragEnter: function(node, sourceNode) {
        /** sourceNode may be null for non-dynatree droppables.
         *  Return false to disallow dropping on node. In this case
         *  onDragOver and onDragLeave are not called.
         *  Return 'over', 'before, or 'after' to force a hitMode.
         *  Any other return value will calc the hitMode from the cursor position.
         */
        logMsg("tree.onDragEnter(%o, %o)", node, sourceNode);
       if(node.data.isFolder)
         return false;
   //     return true;
              return "over";
      },
      onDragOver: function(node, sourceNode, hitMode) {
        /** Return false to disallow dropping this node.
         *
         */
//         if(node.data.isFolder){
//           var dd = $.ui.ddmanager.current;
//           dd.cancel();
//           alert("folder");
//         }
        logMsg("tree.onDragOver(%o, %o, %o)", node, sourceNode, hitMode);
      },
      onDrop: function(node, sourceNode, hitMode, ui, draggable) {
        /**This function MUST be defined to enable dropping of items on the tree.
         * sourceNode may be null, if it is a non-Dynatree droppable.
         */
        logMsg("tree.onDrop(%o, %o)", node, sourceNode);
        var copynode;
        if(sourceNode) {
          copynode = sourceNode.toDict(true, function(dict){
            dict.title = "Copy of " + dict.title;
			dict.hideCheckbox=true;
			$("#tree").dynatree("getTree").activateKey(dict.key);
            // delete dict.key; // Remove key, so a new one will be created
			//Graphen neu zeichnen wenn Filter hinzugefügt und Node aktiviert ist!
			if(node.isSelected()) 
			{
						
				child = [];
				childs="";
				key = node.data.key;
				var key_suche = key.concat("\\+");
				var key_label = key.concat(":cl"); 
				key_filter = key;
							for (var i = 0; i < data.length; i++) {
							var	str2 = data[i].label;
							var str = key_array[i];
							//var res = str.split("+");
							 console.log('key_suche:', key_suche);
								console.log('key_array[i]', str);
						
								if (str.match(key_suche))
								  {
									key_filter=str;
								 console.log("gefunden1");
								  key_array.splice(i,1);
								  }
								   if (str2 === key_label)
								  {
								  console.log("gefunden2");
								  data.splice(i,1);
								   data2.splice(i,1);
								  }
								  
								}
										
											//Children an Key hängen
										
											
											 if (node.hasChildren()==true)
												  { console.log("Child True");
												 
													node.visit(function(n){
														child.push(n.data.key);
														
													});
												
													}
										
										child.push(dict.key);	
										key=key+"+"+child.toString();		
										
										key_array.push(key);
										console.log('KeyArray:', key_array);
										 console.log('Key:', key);
										WerteAktualisieren(timeto, timefrom);
										timeto2=$('#timeto').val();
									 timeto2=timeto2.replace(/ /g,"T");
									 timefrom2=$('#timefrom').val();
									 timefrom2=timefrom2.replace(/ /g,"T");
       
							key1=key_array.join(', '); 
	 
							  //SPARQL string in Textarea schreiben
							  //sparql(timeto, timefrom, errorcheck, showerror, resolution, key1);
							WerteAktualisieren(timeto, timefrom);	 

						n=1;
						while (n <= 2) {
							console.log("Ajax");
							if (n==1)  
							{
							  //Graph zeichnen
									function onDataReceived(series) {
										console.log("Ajax");
										// Extract the first coordinate pair; jQuery has parsed it, so
										// the data is now just an ordinary JavaScript object

										//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";

										// Push the new data onto our existing data array

									
											data.push(series);
										
										
									
						//richtiger Plot
										plot=$.plot("#placeholder", data, options);
						n=n+1;
									}	
								

											$.ajax({
												url: "GetDataPoints.php",
												type: "GET",
												dataType: "json",
												async: false,
												data:{timefrom:timefrom,
											timeto:timeto,
										  //timefrom:"2012-01-06T08:00:00",
											//timeto:"2012-01-06T09:30:00",
											errorcheck:errorcheck,
												showerror:showerror,
												fullcover:fullcover,
											key: key},
												success: onDataReceived,
												//Keine Sensor Daten vorhanden
												error: function ()
												{
													n=n+1;
													key_array.pop();
												
												}
											});
										}	
										
							if (n==2) {
								//Overview zeichnen
							
										function onDataReceived2(series) {

										// Extract the first coordinate pair; jQuery has parsed it, so
										// the data is now just an ordinary JavaScript object

										//var firstcoordinate = "(" + series.data[0][0] + ", " + series.data[0][1] + ")";
									

										// Push the new data onto our existing data array

											data2.push(series);
											
										
										
									
						//overview Plot
								

																$.plot("#overview", data2, options2);
										n=n+1;
											}	
										
											$.ajax({
												url: "GetDataPoints.php",
												type: "GET",
												dataType: "json",
												async: false,
												data:{timefrom:timefrom2,
											timeto:timeto2,
										  //timefrom:"2012-01-06T08:00:00",
											//timeto:"2012-01-06T09:30:00",
											errorcheck:errorcheck,
												showerror:showerror,
												fullcover:fullcover,
											key: key},
												success: onDataReceived2,
												//Keine Sensor Daten vorhanden
												error: function ()
												{
												n=n+1;
												console.log(n);
												}
											});
										}
			
				}
			}
          });
        }else{
          copynode = {title: "This node was dropped here (" + ui.helper + ")."};
        }
        if(hitMode == "over"){
          // Append as child node
          node.addChild(copynode);
          // expand the drop target
          node.expand(true);
        }else if(hitMode == "before"){
          // Add before this, i.e. as child of current parent
          node.parent.addChild(copynode, node);
        }else if(hitMode == "after"){
          // Add after this, i.e. as child of current parent
          node.parent.addChild(copynode, node.getNextSibling());
        }
		
		
      },
      onDragLeave: function(node, sourceNode) {
        /** Always called if onDragEnter was called.
         */
        logMsg("tree.onDragLeave(%o, %o)", node, sourceNode);
		

      }
    }
    });
   
     });
    <!-- (Irrelevant source removed.) -->

</script>

<script type="text/javascript">
$(function(){
  /// --- Initialize second Dynatree (Drag) -------------------------------------------
  $("#tree2").dynatree({
    initAjax: {
       url: "cepruletree.php"
    },
    onLazyRead: function(node){
      // Mockup a slow reqeuest ...
      node.appendAjax({
         url: "cepruletree.php",
                data: {key: node.data.key,
                       mode: "funnyMode"
                         }
      });
    },
    onActivate: function(node) {
      $("#echoActive").text(node.data.title + "(" + node.data.key + ")");
    },
    onDeactivate: function(node) {
      $("#echoActive").text("+");
    },
    dnd: {
      onDragStart: function(node) {
        /** This function MUST be defined to enable dragging for the tree.
         *  Return false to cancel dragging of node.
         */
        logMsg("tree.onDragStart(%o)", node);
        if(node.data.isFolder)
          return false;
        return true;
      },
      onDragStop: function(node) {
        logMsg("tree.onDragStop(%o)", node);
		$("#tree").dynatree("getTree").activateKey(node.data.key);
	
      }
    }
  });
  });
</script>

<script type="text/javascript">

  $(function(){

    $("#download").click(function() {

        
 if ($("#type").val()=="JSON")
   {link=$("#sql").val();
 
   src="http://192.168.0.89:3030/data/query?query="+escape(link)+"&output=json&stylesheet=%2Fxml-to-html.xsl";
   window.open(src,"json");
   }
   else
   {link=$("#sql").val();
	 src="http://192.168.0.89:3030/data/query?query="+escape(link)+"&output=csv&stylesheet=%2Fxml-to-html.xsl";
     window.open(src,"csv"); 
   }
  return false;
    });

    });

</script>

  </head>

  <body class="yui-skin-sam">
    <div class="navbar navbar-static-top navbar-inverse">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
          </a>
          <a class="brand" href="#">
            Sensetrace
          </a>
          <div class="nav-collapse">
            <ul class="nav">
              <li>
                <a href="#">
                  Home
                </a>
              </li>
              <li>
                <a href="#">
                  About
                </a>
              </li>
              <li>
                <a href="#">
                  Contact
                </a>
              </li>
            </ul>
          </div>
          <div class="navbar-form pull-right">
		    <ul class="nav">
             <li>
			 
                <a href="auth/logout.php">
                  Logout
                </a>
              </li>
			  </ul>
          </div>
        </div>
      </div>
    </div>
    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span4">
        
       	 <div class="alert">
  
  <strong>Please note:</strong> Press delete-key to remove selected classification
</div>
         <div class="well well-large" >
		 Choose sensors from tree:
		 <div id="tree">
		 </div>
		 </div>
	
		 <div class="well well-large" >
		 Drag and drop classification to sensortree:
		 <div id="tree2">
		 </div>
		 </div>
    


		
  
 
        </div>
        <div class="span8">
        <div class="well well-large">
   <div class="demo-container">
			<div id="placeholder" class="demo-placeholder"></div>
		</div>
<div class="demo-container" style="height:150px;">
			<div id="overview" class="demo-placeholder"></div>
		</div>
             <hr>
        

 


<form class="form-inline">
 <label>Time from:</label>
  <div id="datetimepicker1" class="input-append date">
    <input data-format="yyyy-MM-dd hh:mm:ss" id="timefrom" type="text" value="2007-01-01 00:00:00"></input>
    <span class="add-on">
      <i data-time-icon="icon-time" data-date-icon="icon-calendar">
      </i>
    </span>
  </div>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   <label>Time to:</label>
    <div id="datetimepicker2" class="input-append date">
    <input data-format="yyyy-MM-dd hh:mm:ss" id="timeto" type="text" value="2007-01-05 08:00:30"></input>
    <span class="add-on">
      <i data-time-icon="icon-time" data-date-icon="icon-calendar">
      </i>
    </span>
  </div>
 
  
</form>
  
<form class="form-inline">
 <label class="checkbox">
        <input type="checkbox" id="datacorrection" checked> Data correction
      </label>
  

  
</form>  
<form class="form-inline">
 <label class="checkbox">
        <input type="checkbox" id="showerrordata"> Show Error Data
      </label>
  
</select>
 
  
</form>  
<form class="form-inline">
 <label class="checkbox">
        <input type="checkbox" id="fullcover"> clid covers full avg interval
      </label>
  
</select>
 
  
</form>  

</div>
<div class="well well-large">
<form class="form-inline">
 <label>SPARQL:</label>
 <textarea rows="4" id="sql" style="width:100%"></textarea>
 </form>
 <br>
 <form class="form-inline">
  <select id="type">
  <option>CSV</option>
  <option>JSON</option>
  </select>
  
  <button type="submit"  id="download" class="btn" disabled='disabled'>Download</button>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     <label>Resolution:</label>
  <select id="resolution">
  <option value="1second">1 second</option>
  <option value="1minute">1 minute</option>
  <option value="15minute">15 minute</option>
  <option value="1hour">1 hour</option>
  <option value="1day">1 day</option>
    <option value="1month">1 month</option>
  <option value="1year">1 year</option>
</select>
 
  
</form>
 

  
        </div>
        </div>
        
        </div>
	
      
        </div>
      </div>
    </div>


</body>
</html>
