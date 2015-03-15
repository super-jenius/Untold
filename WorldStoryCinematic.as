// World Story Cinematic/Panorama
// When icon is clicked, cinematic is downloaded from specified URL and played

class WorldStoryCinematic extends WorldStoryBase
{
	public var m_CinematicURL;
	public var m_Browser;  // background browser instance
	public var m_CinematicTier;
	public var m_Download;

	public function LoadXML(storyNode:XMLNode)
	{
		super.LoadXML(storyNode);
		this.SetURL(storyNode.attributes.url);
	}

	public function SetURL(url:String)
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStory.SetURL()");
		m_CinematicURL = url;
	}
	
	public function PerformAction()
	{
		// Download cinematic
		m_Download = new Download();
		m_Download.SignalDownloadComplete.Connect(PlayCinematic, this);
		m_Download.DownloadFile(escape(m_CinematicURL));
	}
	
	public function PlayCinematic(cinematicXML:String)
	{
		m_Download.SignalDownloadComplete.Disconnect(PlayCinematic, this);
		ULog.Info("WorldStoryCinematic.PlayCinematic()");
		if (cinematicXML.slice(0,5) != "<?xml") {
			// Probably means no xml file exists for current playfield
			ULog.Info("WorldStoryCinematic.PlayCinematic() not XML: " + cinematicXML);
			return;
		}
		
		var xml = new XML();
		xml.ignoreWhite = true;
		xml.parseXML(cinematicXML);
		var mainNode:XMLNode = xml.firstChild;
		if (mainNode == undefined || mainNode == null) {
			ULog.Error("WorldStoryCinematic.PlayCinematic(): XML parsing failed.");
			_root.fifo.SlotShowFIFOMessage("Cinematic XML parsing failed.", 0);
			return;
		}

		m_CinematicTier = new CinematicTier();
		// Public reference so cinematic can be cancelled with Esc key
		_root["untold\\untold"].m_CurrentTier = m_CinematicTier;
		m_CinematicTier.m_Player = m_Player;
		m_CinematicTier.LoadXML(mainNode);
		m_CinematicTier.StartTier();
	}
	
	public function Cleanup()
	{
		m_CinematicTier.AbortTier();
		m_CinematicTier = undefined;
		_root["untold\\untold"].m_CurrentTier = m_CinematicTier;
		super.Cleanup();
	}

}