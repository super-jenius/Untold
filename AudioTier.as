// Audio Tier
// Plays or preloads audio files
// Primarily used for preloading audio that will be played later in dialog or cinematic

class AudioTier extends BaseTier
{
	public var m_URL:String;
	public var m_Preload:String;
	public var m_Volume:Number;
	public var m_Loop:Boolean;
	public var m_Stop:Boolean;
	public var m_Player:AudioPlayer;

	public function AudioTier()
	{
		m_SkipPrev = true;
		m_NoBell = true;
	}
	
	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("AudioTier.LoadXML()");
		this.SetAudio(tierNode.attributes.url, tierNode.attributes.preload, Number(tierNode.attributes.volume), Boolean(tierNode.attributes.loop), 
			Boolean(tierNode.attributes.stop), Boolean(tierNode.attributes.muteMusic));
	}

	public function SetAudio(url:String, preload:String, volume:Number, loop:Boolean, stop:Boolean)
	{
		m_URL = url;
		m_Preload = preload;
		m_Volume = volume;
		m_Loop = loop;
		m_Stop = stop;
	}
	
	public function StartTier()
	{
		ULog.Info("AudioTier.StartTier(): url=" + m_URL);
		m_Player = _root["untold\\untold"].GetAudioPlayer();
		var thisTier = this;
		if (m_Preload == "wait") {
			// Wait for preload to complete before moving to next tier
			m_Player.onPreloadComplete = function() {
				thisTier.EndTier();
			}
		} 		
		m_Player.PlayAudio(m_URL, m_Preload, m_Volume, m_Loop, m_Stop);
		if (m_Preload != "wait") {
			// Move immediately to next tier
			this.EndTier();
		}
	}
	
	public function StopAudio()
	{
		if (m_Player) {
			m_Player.StopAudio();
			m_Player = undefined;
		}
	}

}