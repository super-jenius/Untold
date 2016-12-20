
// function onLoadFn() {
//     // Make gapi.client calls
//     document.writeln('onLoadFn');
//     getPlaylist();
// }

function handleAPILoaded() {
    console.log('handleAPILoaded');
    //alert("handleAPILoaded");
    getPlaylist();
}

function loadYoutube() {
    console.log('loadYoutube');
    gapi.client.setApiKey('AIzaSyARvwirFktEIi_BTaKcCi9Ja-m3IEJYIRk');
    gapi.client.load('youtube', 'v3', function () {
        handleAPILoaded();
    });
}

function getPlaylist() {
    console.log('getPlaylist');
    //alert("getPlaylist");
    playlistId = "PLQkGzWWADni6ByUihvxWbjaldx9NegDwf";
    var requestOptions = {
        playlistId: playlistId,
        part: 'contentDetails',
        maxResults: 50
    };

    var request = gapi.client.youtube.playlistItems.list(requestOptions);
    request.execute(function (response) {
        var playlistItems = response.result.items;
        var videoIds = "";
        if (playlistItems) {
            $.each(playlistItems, function (index, item) {
                console.log(item.contentDetails);
                videoIds += "," + item.contentDetails.videoId;
            });
            console.log(videoIds);
        } else {
            console.log('Sorry you have no uploaded videos');
        }
        if (videoIds != "") {
            videoIds = videoIds.substr(1);
            getVideos(videoIds);
        }
    });

}

function getVideos(videoIds) {
    console.log("getVideos");
    var requestOptions = {
        id: videoIds,
        part: 'contentDetails',
        maxResults: 50
    };

    var request = gapi.client.youtube.videos.list(requestOptions);
    request.execute(function (response) {
        var videoItems = response.result.items;
        var videoIds = "";
        if (videoItems) {
            $.each(videoItems, function (index, item) {
                console.log(item.contentDetails);
            });
        } else {
            console.log('Sorry you have no uploaded videos');
        }
    });
    
}

