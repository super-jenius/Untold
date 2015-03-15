// Download file and send contents back to TSW in data URL
import com.GameInterface.Browser.Browser;
import com.Utils.Signal;

class Download
{
	public var m_Browser; // background browser instance
	public var m_BrowserSignal;
	//public var m_BaseURL = "file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/";
	public var m_BaseURL = "http://untoldworld.azurewebsites.net/";
	public var SignalDownloadComplete:Signal;
	
	public function Download()
	{
		SignalDownloadComplete = new Signal();
	}

	public function DownloadFile(filename)
	{
		// Use background browser 
		if (m_Browser == undefined) {
			m_Browser = _root["untold\\untold"].GetBackgroundBrowser();
		}
		this.TrackURL();
		var url = m_BaseURL + "download.html?filename=" + escape(filename);
		ULog.Info("Download.DownloadFile(): " + url);
		m_Browser.OpenURL(url);
	}

	// Track when URL changes
	// This is the only way the browser can send data back to TSW
	public function TrackURL()
	{
		m_BrowserSignal = m_Browser.SignalStartLoadingURL;
		if (m_BrowserSignal) {
			ULog.Info("Download.TrackURL(): Tracking SignalStartLoadingURL");
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
		if (url.slice(0, 15) == "data:,download=")
		{
			// Disconnect browser signal
			m_BrowserSignal.Disconnect(URLChanged, this);
			// Release browser
			m_Browser = undefined;
			_root["untold\\untold"].ReleaseBackgroundBrowser();
			// Send file contents back
			var fileContents = url.slice(15);
			SignalDownloadComplete.Emit(fileContents);
		} 
		else if ((url.slice(0, 11) == "data:,error")) {
			// Disconnect browser signal
			m_BrowserSignal.Disconnect(URLChanged, this);
			// Release browser
			m_Browser = undefined;
			_root["untold\\untold"].ReleaseBackgroundBrowser();
			// Log error
			ULog.Error("Download.URLChanged(): " + url);
			_root.fifo.SlotShowFIFOMessage("Download.URLChanged() Error: " + url);
		}
	}
	
}
