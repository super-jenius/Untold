// Untold Stories Audio Player
// Downloads and plays audio from web using browser in the background
// Can play or preload audio
// Preloading ahead of time recommended so timing more predicabale.
// Only one file can be preloaded at a time.
import com.GameInterface.Browser.Browser;
import com.GameInterface.DistributedValue;

class AudioPlayer
{

	public function PlayAudio(audioURL, preload, volume, loop, stop)
	{
		if (stop == true) {
			this.StopAudio();
			return;
		}
		
		//var baseURL = "file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/";
		var baseURL = "http://untoldworld.azurewebsites.net/";
		
		var url = baseURL + "audioplayer.html?src=" + escape(audioURL);
		if (preload == true) {
			url = url + "&preload=true";
		}
		// Volume format is 0 to 100, but will change to web format of 0 to 1
		if (volume) {
			var webVolume = volume/100;
			url = url + "&volume=" + webVolume.toString();
		}
		if (loop == true) {
			url = url + "&loop=true";
		}
		
		var browser = _root["untold\\untold"].GetBackgroundBrowser();
		ULog.Info("AudioPlayer.PlayAudio(): " + url);
		browser.OpenURL(url);
	}
	
	// Stop existing audio by loading an empty url
	public function StopAudio()
	{
		_root["untold\\untold"].ReleaseBackgroundBrowser();
	}
	
}