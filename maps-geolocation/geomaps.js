console.log('started!');
/*
Future improvements:
	- putting all functions in a named var object might give more flexibility for passing variables around in callbacks

*/

$(document).ready(function(){
	loadLocation();
});
/* 
	Access browser geolocation
*/
function loadLocation(){
    if(navigator.geolocation) {		
		navigator.geolocation.getCurrentPosition(getLocation);		
    } else {
    	alert('browser geolocation not available');
    }   
}

/*
	Get current geo position
*/
function getLocation(position) {
	//console.log(position.coords);
	var lat = position.coords.latitude;
    var lng = position.coords.longitude;
    
	if (!lat || !lng) {
    	alert('Could not retrieve location');
        return;
    }
    // fetch the API results based on this location
    getRestrooms(lat,lng);
}

/*
	Set up the map
*/
function makeMap(lat,lng) {	
	if (!lat || !lng){
		lat = 40.7143528;
		lng = -74.0059731;
	}
    mapOptions = {
      center: new google.maps.LatLng(lat,lng),
      zoom: 12
    };
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

    // set up info window, to be attached to markers
    infowindow = new google.maps.InfoWindow({content:''});
 }

/*
	Query the Restrooms API
*/
function getRestrooms(lat,lng){
	var url = "http://fortytonone.herokuapp.com/search_bathrooms.json?";
	url += "lat="+lat+"&";
	url += "long="+lng;
	$.get(url, function (response) {
		// hide the loading icon
		$('#loading').hide();
		// Make the initial map
 		makeMap(lat,lng); 		

 		// Send each address to be geocoded. 
        for (var i in response.bathrooms){
        	console.log(response.bathrooms[i].name);
        	/*
        	 sending the name to the geoCode func too, so that it's available in the callback 
        	 	-- there must be a more sensible way!
        	*/
        	geoCodeAddress(response.bathrooms[i].location,response.bathrooms[i].name,function(posObj){ 
        		//console.log(posObj);
        		// set up markers
        		var myLatlng = new google.maps.LatLng(posObj.la,posObj.lo);
	        	var marker = new google.maps.Marker({
					map: map,
					position: myLatlng,
					infowindow_content: posObj.location_name // custom property to set name of marker
				});
				// set up info windows
				google.maps.event.addListener(marker, 'click', function(){
		 			infowindow.setContent(this.infowindow_content);
		 			infowindow.open(map, this);
		 		});	
	        });	
        } 
	});	
}


/*
	Turn an address into lat/long coordinates
*/
function geoCodeAddress(addr,txt,callback){
	// example: http://maps.googleapis.com/maps/api/geocode/json?address=350+5th+Avenue+New+York%2C+NY&sensor=false
	var url = "http://maps.googleapis.com/maps/api/geocode/json?address=";
	url += encodeURIComponent(addr);
	url += "&sensor=false";
	$.ajax({
       type: 'GET',
        url: url,
        // Add markers to the map for each bathroom location
        success: function(response){ 
        	var lat = response.results[0].geometry.location.lat;
        	var lng = response.results[0].geometry.location.lng;
        	
	 		// send back the lat/long info
	 		callback({la:lat,lo:lng,location_name:txt});
        }
    });
}





