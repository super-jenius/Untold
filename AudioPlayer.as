// Untold Stories Audio Player
// Downloads and plays audio from web using browser in the background
// Can play or preload audio
// Preloading ahead of time recommended so timing more predicabale.
// Only one file can be preloaded at a time.
import com.GameInterface.Browser.Browser;
import com.GameInterface.DistributedValue;

class AudioPlayer
{

	public var m_Browser; // background browser instance
	public var m_BrowserSignal;
	
	public function PlayAudio(audioURL, preload, volume, loop, stop)
	{
		if (stop == true) {
			this.StopAudio();
			return;
		}
		
		var baseURL = "file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/web/";
		//var baseURL = "http://untoldworld.azurewebsites.net/";
		
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
		
		m_Browser = _root["untold\\untold"].GetBackgroundBrowser();
		this.TrackURL();
		ULog.Info("AudioPlayer.PlayAudio(): " + url);
		m_Browser.OpenURL(url);
	}
	
	// Stop existing audio by loading an empty url
	public function StopAudio()
	{
		_root["untold\\untold"].ReleaseBackgroundBrowser();
	}
	
	// Track when URL changes
	// This is the only way the browser can send data back to TSW
	public function TrackURL()
	{
		m_BrowserSignal = m_Browser.SignalStartLoadingURL;
		if (m_BrowserSignal) {
			ULog.Info("AudioPlayer.TrackURL(): Tracking SignalStartLoadingURL");
			m_BrowserSignal.Connect(URLChanged, this);
		}
		else {
			// Browser takes a bit to load, so retry until it is loaded
			// Use _global.setTimeout to avoid scoping issues
			_global.setTimeout(this, "TrackURL", 100);
		}
	}	
	
	function URLChanged(newurl:String) {
		var url = unescape(newurl);
		_root.fifo.SlotShowFIFOMessage("AudioPlayer.URLChanged: " + url);
		// Release browser when audio is complete
		if (url == "data:,audiocomplete")
		{
			// Disconnect browser signal
			m_BrowserSignal.Disconnect(URLChanged, this);
			// Release browser
			m_Browser = undefined;
			this.StopAudio();
		}
	}

}