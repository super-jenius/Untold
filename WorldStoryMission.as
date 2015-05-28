// World Story Mission
// When icon is clicked, mission is downloaded from specified URL and started
// Missions can co-exist with main mission list, or can be "hidden" missions on lore only
// Lore-only missions can't be reset, but they can be paused and resumed, by going back to the original location and starting again.

class WorldStoryMission extends WorldStoryBase
{
	public var m_MissionURL;
	public var m_Download;

	public function LoadXML(storyNode:XMLNode)
	{
		super.LoadXML(storyNode);
		this.SetURL(storyNode.attributes.url);
		m_IconType = "BreakingItemsIcon";
	}

	public function SetURL(url:String)
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStory.SetURL()");
		m_MissionURL = url;
	}
	
	public function PerformAction()
	{
		// Download cinematic
		m_Download = new Download();
		m_Download.SignalDownloadComplete.Connect(StartMission, this);
		m_Download.DownloadFile(escape(m_MissionURL));
	}
	
	public function StartMission(missionXML:String)
	{
		m_Download.SignalDownloadComplete.Disconnect(StartMission, this);
		ULog.Info("WorldStoryMission.StartMission()");
		if (missionXML.slice(0,5) != "<?xml") {
			// Probably means no xml file exists for current playfield
			ULog.Info("WorldStoryMission.StartMission() not XML: " + missionXML);
			return;
		}
		
		_root["untold\\untold"].m_MissionListWindow.m_Content.LoadWebMission(m_StoryID, missionXML);
	}
	
	public function ShowIcon()
	{
		var status = _root["untold\\untold"].m_MissionListWindow.m_Content.m_MissionStatus;
		status.GetStatus(m_StoryID);
		if (status.m_Status <> "")
		{
			m_AddlInfo = "\nStatus: " + status.m_Status;
		}
		super.ShowIcon();
	}

	public function Cleanup()
	{
		super.Cleanup();
	}

}