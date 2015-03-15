// World Story base class
// Allows stories to be placed throughout the game world
// When user is within range of specified location, an icon is displayed in the notification area
// If icon is clicked, then an action is performed (specified in subclass)
// If users exits the range of the location, the icon is removed
// There can be multiple icons active at one time

class WorldStoryBase
{
	public var m_StoryID;
	public var m_Type;	// story, art, video, etc.
	public var m_StoryTitle;
	public var m_SubTitle = "";
	public var m_Teaser; // Optional FIFO teaser message when player gets in range
	public var m_LocationTier;
	public var m_USIcon;
	public var m_AtLocation;
	public var m_IntervalID;
	public var m_Player:PlayerInfo;
	
	public function WorldStoryBase()
	{
		m_Player = new PlayerInfo();
	}
 
 	public function LoadXML(storyNode:XMLNode)
	{
		m_StoryID = storyNode.attributes.id;
		m_Type = storyNode.attributes.type;
		m_StoryTitle = storyNode.attributes.title;
		//_root.fifo.SlotShowFIFOMessage(m_StoryTitle);
		if (storyNode.attributes.subtitle) {
			m_SubTitle = storyNode.attributes.subtitle;
		}
		m_Teaser = storyNode.attributes.teaser;
		this.SetLocation(Number(storyNode.attributes.playField), Number(storyNode.attributes.x), Number(storyNode.attributes.y), 
						 Number(storyNode.attributes.z), Number(storyNode.attributes.distance), Number(storyNode.attributes.yDistance));
	}

	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number)
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStoryBase.SetLocation()");
		m_LocationTier = new LocationTier();
		m_LocationTier.m_Player = m_Player;
		m_LocationTier.SetLocation(playField, x, y, z, distance, yDistance);
	}

	// Start tracking location
	public function StartTracking()
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStoryBase.StartTracking()");
		m_AtLocation = false;
		m_IntervalID = setInterval(this, "CheckLocation", 500);
	}
	
	public function StopTracking()
	{
		clearInterval(m_IntervalID);
		this.DestroyIcon();
	}

	public function CheckLocation()
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStory.CheckLocation()");
		if (m_LocationTier.CheckLocation() == true) {
			if (m_AtLocation == false) {	// If we were already at the location, do nothing
				m_AtLocation = true;
				this.DisplayTeaser();
				this.ShowIcon();
			}
		} else {
			if (m_AtLocation == true) {	// If we were already outside the location do nothing
				m_AtLocation = false;
				this.DestroyIcon();
			}
		}
	}
	
	public function DisplayTeaser()
	{
		// Play teaser sound
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_group_invited.xml");
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_loot_bag_open.xml");
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_loot_bag_take_item.xml");
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_power_wheel_movement.xml"); // subtle
		m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_purchase_power.xml"); // varies with each play
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_spend_skill_point.xml"); 
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_trade_success.xml"); 
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_window_open.xml"); // subtle but audible
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_PvP_MiniGame_PopUp.xml");
		// Display optional teaser
		if (m_Teaser <> undefined && m_Teaser <> null && m_Teaser <> "") {
			_root.fifo.SlotShowFIFOMessage(m_Teaser);
		}
	}
	
	public function ShowIcon()
	{
		var link = _root.animawheellink;

		// Create icon if it doesn't already exist
		if (m_USIcon == undefined || link["m_USIcon_" + m_StoryID] == undefined)
		{
			m_USIcon = link.attachMovie("BrokenItemsIcon", "m_USIcon_" + m_StoryID, link.getNextHighestDepth());
			link.SetVisible(m_USIcon, false);
			m_USIcon.createTextField("m_NotificationText", m_USIcon.getNextHighestDepth(), 0, 1, 35, 33.10);
			m_USIcon.m_NotificationText.text = "US"; 
			var fmt:TextFormat = new TextFormat();
			fmt.align = "center";
			fmt.bold = true;
			fmt.color = 16777215;
			fmt.font = "Futura Heavy Fix";
			fmt.size = 23;
			fmt.leading = 2;
			m_USIcon.m_NotificationText.setTextFormat(fmt);
			// m_USIcon.fmt = m_USIcon.m_NotificationText.getTextFormat();
			link.CreateRealTooltip(m_USIcon, "Untold Stories\nof The Secret World", m_Type + ": " + m_StoryTitle + "\n" + m_SubTitle);
			
			// Single click opens URL. Double-click hides icon.
			var intervalID = 0;
			var clickNum = 0;
			var thisStory = this;
			m_USIcon.onPress = function(){
				clickNum++;
				if (clickNum == 1) {
					intervalID = setInterval(function() {
						// Single click
						clickNum = 0;
						clearInterval(intervalID);
						thisStory.HideIcon();
						thisStory.PerformAction();
						//_root.fifo.SlotShowFIFOMessage("Single click");
				   }, 400);
				} else {
					// Double click
					clickNum = 0;
					clearInterval(intervalID);
					thisStory.HideIcon();
					//_root.fifo.SlotShowFIFOMessage("Double click");
				}
			}
		}
		
		// Show icon
		link.SetVisible(m_USIcon, true);
	}
	
	public function HideIcon()
	{
		if (m_USIcon) {
			var link = _root.animawheellink;
			link.SetVisible(m_USIcon, false);
		}
	}
	
	public function DestroyIcon()
	{
		if (m_USIcon) {
			this.HideIcon();
			m_USIcon.removeMovieClip();
			m_USIcon = undefined;
		}
	}
	
	public function PerformAction()
	{
		// Action specified in subclass
	}
	
	// Cleanup function should be called before releasing object
	public function Cleanup()
	{
		this.StopTracking();
		m_LocationTier = undefined;
	}


}

