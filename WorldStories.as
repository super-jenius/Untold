// Untold Stories Lore (fka "World Stories")
// Handles stories spread throughout the game world
// Loads an xml file for each playField containing locations and info about the stories
import com.GameInterface.WaypointInterface;

class WorldStories
{
	public var m_Stories:Array;
	public var m_Player;
	public var m_CurrentField;
	public var m_Download;
	
	public function WorldStories()
	{
		ULog.Info("WorldStories.WorldStories()");
		m_Player = new PlayerInfo();
		this.DownloadPlayField();
	}
	
	// Download XML file for current playfield
	public function DownloadPlayField(newPlayfield:Number)
	{
		if (newPlayfield == undefined) {
			newPlayfield = m_Player.m_Character.GetPlayfieldID();
		}
		if (m_CurrentField <> newPlayfield) {
			m_CurrentField = newPlayfield;
			this.Cleanup();
			WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
			
			// Download world XML file
			if (m_Download == undefined) {
				m_Download = new Download();
			}
			m_Download.SignalDownloadComplete.Connect(LoadXML, this);
			var filename = "world_" + m_CurrentField.toString() + ".xml";
			m_Download.DownloadFile(filename);
			ULog.Info("WorldStories.DownloadPlayField(): " + filename);
		}
	}

	// Load new XML file when playfield changed
	public function SlotPlayfieldChanged(newPlayfield:Number)
	{
		ULog.Info("WorldStories.SlotPlayfieldChanged(): " + newPlayfield.toString());
		this.DownloadPlayField(newPlayfield);
	}

	// Load World XML
	public function LoadXML(worldXML:String)
	{
		m_Download.SignalDownloadComplete.Disconnect(LoadXML, this);
		ULog.Info("WorldStories.LoadXML()");
		if (worldXML.slice(0,5) != "<?xml") {
			// Probably means no xml file exists for current playfield
			ULog.Info("WorldStories.LoadXML() not XML: " + worldXML);
			return;
		}
		var xml = new XML();
		xml.ignoreWhite = true;
		xml.parseXML(worldXML);
		var worldNode:XMLNode = xml.firstChild;
		if (worldNode == undefined || worldNode == null) {
			ULog.Error("WorldStories.LoadXML(): XML parsing failed.");
			_root.fifo.SlotShowFIFOMessage("Lore XML parsing failed.", 0);
			return;
		}
		// Double-check that playfield in XML file is same as current playfield
		var xmlPlayField = worldNode.attributes.playfield;
		if (xmlPlayField <> m_CurrentField.toString()) {
			_root.fifo.SlotShowFIFOMessage("WorldStories.LoadXML(): Lore PlayField Error");
			ULog.Error("WorldStories.LoadXML() PlayField Error: XML playfield - " + xmlPlayField + ", Current playfield - " + m_CurrentField.toString());
			return;
		}

		// Add stories to array
		m_Stories = new Array();
		for (var i = 0; i < worldNode.childNodes.length; i++)
		{
			var storyNode:XMLNode = worldNode.childNodes[i];
			if (storyNode) {
				var storyType = storyNode.attributes.type;
				var storyFaction = storyNode.attributes.faction;
				var storyGender = storyNode.attributes.gender;
				var minVer = storyNode.attributes.minVer;
				// Check faction and gender requirements
				if ((storyFaction == undefined || storyFaction == "" || storyFaction.toLowerCase() == m_Player.m_Faction.toLowerCase()) &&
					(storyGender == undefined || storyGender == "" || storyGender.toLowerCase() == m_Player.m_Gender.toLowerCase()) &&
					(minVer == undefined || minVer <=  _root["untold\\untold"].m_VerNo))
				{
					switch (storyType.toLowerCase()) {
					case "panorama" :
					case "cinematic" :
						// Cinematic/Panorama
						if (storyNode.attributes.url) {
							var story = new WorldStoryCinematic();
							
							story.LoadXML(storyNode);
							story.StartTracking();
							m_Stories.push(story);
						}
						break;
					case "mission" :
						// Mission
						if (storyNode.attributes.url) {
							var story = new WorldStoryMission();
							
							story.LoadXML(storyNode);
							story.StartTracking();
							m_Stories.push(story);
						}
						break;
					default :
						// The rest of the types use the browser
						if (storyNode.attributes.url) {
							var story = new WorldStoryBrowser();
							
							story.LoadXML(storyNode);
							story.StartTracking();
							m_Stories.push(story);
						}
					}
				}
			}
		}
	}

	// Cleanup current stories before loading new ones
	public function Cleanup()
	{
		WaypointInterface.SignalPlayfieldChanged.Disconnect(SlotPlayfieldChanged, this);
		for (var i = 0; i < m_Stories.length; i++) {
			m_Stories[i].Cleanup();
			m_Stories[i] = undefined;
		}
		m_Stories.splice(0);
		m_Stories = undefined;
	}
	
	// Unload World Stories when disabled
	public function Unload()
	{
		this.Cleanup();
		m_Download = undefined;	
	}

}