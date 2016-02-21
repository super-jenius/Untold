// Untold Stories Audio Player
// Downloads and plays audio from web using browser in the background
// Can play or preload audio
// Preloading ahead of time recommended so timing more predicabale.
// Only one file can be preloaded at a time.
import com.GameInterface.Browser.Browser;
import com.GameInterface.DistributedValue;

class AudioPlayer
{

	public var m_BrowserSignal;
	public var m_MuteMusic;
	public var m_BackgroundVolume;
	public var m_CombatVolume;
	public var m_RadioVolume;
	public var m_AlreadyMute;
	
	public function PlayAudio(audioURL, preload, volume, loop, stop, muteMusic)
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
		
		var browser = _root["untold\\untold"].GetBackgroundBrowser();
		this.TrackURL(browser);
		ULog.Info("AudioPlayer.PlayAudio(): " + url);
		browser.OpenURL(url);
		
		m_MuteMusic = muteMusic;
		MuteMusic();
	}
	
	// Stop existing audio by loading an empty url
	public function StopAudio()
	{
		ULog.Info("AudioPlayer.StopAudio()");
		RestoreMusic();
		// Disconnect browser signal
		m_BrowserSignal.Disconnect(URLChanged, this);
		_root["untold\\untold"].ReleaseBackgroundBrowser();
	}
	
	// Track when URL changes
	// This is the only way the browser can send data back to TSW
	public function TrackURL(browser)
	{
		m_BrowserSignal = browser.SignalStartLoadingURL;
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
		//_root.fifo.SlotShowFIFOMessage("AudioPlayer.URLChanged: " + url);
		// Release browser when audio is complete
		if (url == "data:,audiocomplete")
		{
			this.StopAudio();
		}
	}
	
	// Mute music while audio plays
	function MuteMusic()
	{
		if (m_MuteMusic == true && m_AlreadyMute != true) {
			// Save current volume settings to restore when audio stops
			m_BackgroundVolume = DistributedValue.GetDValue("AudioVolumeBackgroundMusic");
			m_CombatVolume = DistributedValue.GetDValue("AudioVolumeCombatMusic");
			m_RadioVolume = DistributedValue.GetDValue("AudioVolumeRadioMusic");

			DistributedValue.SetDValue("AudioVolumeBackgroundMusic", 0);
			DistributedValue.SetDValue("AudioVolumeCombatMusic", 0);
			DistributedValue.SetDValue("AudioVolumeRadioMusic", 0);
			m_AlreadyMute = true;
			ULog.Info("MuteMusic() Background: " + m_BackgroundVolume + " Combat: " + m_CombatVolume + " Radio: " + m_RadioVolume);
		}
	}
	
	// Restore music volume if it has been muted
	function RestoreMusic()
	{
		if (m_MuteMusic == true || m_AlreadyMute == true) {
			// Restore previous volume settings 
			DistributedValue.SetDValue("AudioVolumeBackgroundMusic", m_BackgroundVolume);
			DistributedValue.SetDValue("AudioVolumeCombatMusic", m_CombatVolume);
			DistributedValue.SetDValue("AudioVolumeRadioMusic", m_RadioVolume);
			m_AlreadyMute = false;
		}
	}

}