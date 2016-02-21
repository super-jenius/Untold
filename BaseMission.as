// Base Mission class
// Drives mission tiers.  Base mission scripts on this class.
import com.GameInterface.Utils;
import com.GameInterface.DistributedValue;

class BaseMission
{
	public var m_Tiers:Array = new Array();
	public var m_CurrentTierNo;
	public var m_MaxTierNo;
	public var m_CurrentTier:BaseTier;
	public var m_PrevTier;
	public var m_CustomWindow;
	public var m_MissionTitle;
	public var m_MissionID;
	public var m_MissionStatus:MissionStatus;
	public var m_Player:PlayerInfo;
	public var m_MissionCompleteMessage = "Mission Complete.";
	public var m_Aborting = false;
	
	public function BaseMission()
	{
		m_Player = new PlayerInfo();
	}
	
	public function ScriptMission()
	{
		// Mission scripting goes here in subclass
	}

	public function LoadXML(missionXML:XML)
	{
		ULog.Info("BaseMission.LoadXML()");
		var missionNode:XMLNode = missionXML.firstChild;
		if (missionNode == undefined || missionNode == null) {
			ULog.Error("BaseMission.LoadXML(): XML parsing failed.");
			_root.fifo.SlotShowFIFOMessage("Mission XML parsing failed.", 0);
			return;
		}
		m_MissionTitle = missionNode.attributes.title;
		if (missionNode.attributes.debugMode == "true") {
			_global.m_MissionDebugWindow._visible = true;
		}			
		
		for (var i = 0; i < missionNode.childNodes.length; i++)
		{
			var tierNode:XMLNode = missionNode.childNodes[i];
			if (tierNode) {
				var tierType = tierNode.attributes.type;
				var tierDescription = tierNode.attributes.description;
				var tierFaction = tierNode.attributes.faction;
				var tierGender = tierNode.attributes.gender;
				var tierSkipPrev = tierNode.attributes.skipPrev;
				var tierNoBell = tierNode.attributes.noBell;
				// Check faction and gender requirements
				if ((tierFaction == undefined || tierFaction == "" || tierFaction.toLowerCase() == m_Player.m_Faction.toLowerCase()) &&
					(tierGender == undefined || tierGender == "" || tierGender.toLowerCase() == m_Player.m_Gender.toLowerCase()))
				{
					// Add tier
					var tier:BaseTier = this.AddTier(tierType, tierDescription, tierSkipPrev, tierNoBell);
					// Tier handles rest of XML for the node
					tier.LoadXML(tierNode);	
					// Reference to this object available during LoadXML() only
					// Remove circular reference
					tier.m_Mission = undefined;
				}
			}
		}
		
		// Get mission status
		m_MissionStatus.GetStatus(m_MissionID);
		switch (m_MissionStatus.m_Tier) {
		case -99 :	
			// Already complete. Start over, but allow access to all tiers.
			m_CurrentTierNo = -1;
			m_MaxTierNo = m_Tiers.length - 1;
			break;
		case -1 :	
			// Not started
			m_CurrentTierNo = -1;
			m_MaxTierNo = 0;
			break;
		default :	
			// In progress. Resume at previous tier.
			m_CurrentTierNo = m_MissionStatus.m_Tier - 1;
			m_MaxTierNo = m_MissionStatus.m_Tier - 1;
			break;
		}
		
		// If debugTier specified in script, use it
		var debugTier = Number(missionNode.attributes.debugTier)
		if (debugTier > 0) {
			m_CurrentTierNo = debugTier - 1;
			m_MaxTierNo = debugTier - 1;
		}
	}

	// Add tier and return object for further scripting
	public function AddTier(tierType:String, tierDescription:String, tierSkipPrev:Boolean, tierNoBell:Boolean)
	{
		var newTier:BaseTier;
		
		switch(tierType.toLowerCase()) 
		{
			case "target" :
				newTier = new TargetTier();
				break;
			case "dialog" :
				newTier = new DialogTier();
				break;
			case "kill" :
				newTier = new KillTier();
				break;
			case "location" :
				newTier = new LocationTier();
				break;
			case "browser" :
				newTier = new BrowserTier();
				break;
			case "additem" :
				newTier = new AddItemTier();
				break;
			case "useitem" :
				newTier = new UseItemTier();
				break;
			case "move" :
				newTier = new MoveTier();
				break;
			case "cinematic" :
				newTier = new CinematicTier();
				break;
			case "audio" :
				newTier = new AudioTier();
				break;
			case "looks" :
				newTier = new LooksTier();
				break;
			case "animation" :
				newTier = new AnimationTier();
				break;
			case "response" :
				newTier = new BrowserResponseTier();
				break;				
		}

		newTier.m_TierType = tierType;
		newTier.m_TierDescription = tierDescription;
		newTier.m_Player = m_Player;
		newTier.m_Mission = this;
		if (tierSkipPrev != undefined) {
			newTier.m_SkipPrev = Boolean(tierSkipPrev);
		}
		if (tierNoBell != undefined) {
			newTier.m_NoBell = Boolean(tierNoBell);
		}
		m_Tiers.push(newTier);	

		//this.MessageBox("Tier Added.");

		return newTier;
	}
	
	public function StartMission(customWindow)
	{
		ULog.Info("BaseMission.StartMission(): " + m_MissionID + " " + m_MissionTitle);
		if (customWindow == undefined) {
			ULog.Error("BaseMission.StartMission(): customWindow undefined");
		}
		if (m_Tiers.length <= 0) {
			ULog.Error("BaseMission.StartMission(): No tiers");
			this.onMissionComplete();
			return;
		}
		m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_mission_get.xml");
		m_CustomWindow = customWindow;
		m_CustomWindow.titleTextField.text = this.m_MissionTitle;
		m_CustomWindow.prevButton._visible = false;
		m_CustomWindow.nextButton._visible = false;
		m_CustomWindow.prevButton.addEventListener("click", this, "PreviousTier");	
		m_CustomWindow.nextButton.addEventListener("click", this, "SkipTier");	
		m_CustomWindow._visible = true;
		// Hook up debug previous/next buttons
		if (_global.m_MissionDebugWindow._visible == true)
		{
			_global.m_MissionDebugWindow.prevButton.addEventListener("click", this, "PreviousTier");	
			_global.m_MissionDebugWindow.nextButton.addEventListener("click", this, "SkipTier");	
		}
		m_Aborting = false;
		m_PrevTier = false;
		this.StartNextTier();
	}
	
	public function StartNextTier()
	{
		ULog.Info("BaseMission.StartNextTier(): m_PrevTier=" + m_PrevTier.toString());
		if (m_PrevTier == true)
		{
			m_PrevTier = false;
			if (m_CurrentTierNo > 0)
			{
				m_CurrentTierNo--;
				// If skipping backward, skip again past certain tiers (cinematics, audio, etc.), or player can get stuck
				if (m_Tiers[m_CurrentTierNo].m_SkipPrev == true) {
					m_PrevTier = true;
					this.StartNextTier();
					return;
				}
			}
		}
		else
		{
			m_CurrentTierNo++;
			if (m_CurrentTierNo > m_MaxTierNo)
			{
				m_MaxTierNo = m_CurrentTierNo;
				if (m_Aborting == false)	{
					m_MissionStatus.SetTier(m_MissionID, m_MaxTierNo);
				}
			}
		}
		
		//m_CurrentTier = m_Tiers.shift();
		m_CurrentTier = m_Tiers[m_CurrentTierNo];
		// Public reference to current tier
		_root["untold\\untold"].m_CurrentTier = m_CurrentTier;
		
		if (m_CurrentTier) {
			// Update mission description
			this.UpdateDescription();
			// Create reference to this so event handlers below can see it and call back
			var thisMission = this;
			var thisTier = m_CurrentTier;
			// When tier complete, move on to next tier
			m_CurrentTier.onTierComplete = function() {
				ULog.Info("BaseMission.StartNextTier(): onTierComplete");
				//thisMission.MessageBox("Tier Complete");
				if (thisTier.m_NoBell != true) {
					//Utils.PlayFeedbackSound("sfx/gui/gui_tier_complete.wav");
					//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
					//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_lore_get.xml");
					//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_tier_complete.xml");
					m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_goal_complete.xml");
					//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_mission_complete.xml");
					//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_mission_get.xml");
				}
				thisMission.StartNextTier();
			}

			// Update progress
			m_CurrentTier.onTierProgress = function() {
				thisMission.UpdateDescription();
			}

			// Start tier
			m_CurrentTier.m_TierEnded = false;
			m_CurrentTier.StartTier();
			//this.MessageBox("Tier Started");
		} else {
			m_CustomWindow._visible = false;
			if (m_Aborting == true)	{
				m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_tier_complete.xml");
				m_CustomWindow.contentTextField.text = "Mission paused.";
				//this.MessageBox("Mission Aborted.");
				_root.fifo.SlotShowFIFOMessage("Mission Paused.", 0);
			}
			else {
				m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_mission_complete.xml");
				m_CustomWindow.contentTextField.text = "Mission complete.";
				//this.MessageBox(m_MissionCompleteMessage);
				_root.fifo.SlotShowFIFOMessage(m_MissionCompleteMessage, 0);
				m_MissionStatus.SetTier(m_MissionID, -99);
			}
			this.onMissionComplete();
		}
	}

	// Update mission description
	public function UpdateDescription()
	{
		ULog.Info("BaseMission.UpdateDescription(): " + m_CurrentTier.m_TierDescription + " " + m_CurrentTier.m_TierProgress);
		this.m_CustomWindow.contentTextField.text = m_CurrentTier.m_TierDescription + " " + m_CurrentTier.m_TierProgress;
		if (m_CurrentTierNo > 0)
		{
			this.m_CustomWindow.prevButton._visible = true;
		}
		else
		{
			this.m_CustomWindow.prevButton._visible = false;
		}
		if (m_CurrentTierNo < m_MaxTierNo)
		{
			this.m_CustomWindow.nextButton._visible = true;
		}
		else
		{
			this.m_CustomWindow.nextButton._visible = false;
		}
	}

	public function AbortMission()
	{
		ULog.Info("BaseMission.AbortMission()");
		m_Aborting = true;
		m_Tiers.splice(0);
		m_Tiers = null;
		m_CustomWindow._visible = false;
		m_CurrentTier.AbortTier();
		m_CurrentTier = null;
	}

	public function SkipTier()
	{
		ULog.Info("BaseMission.SkipTier()");
		Selection.setFocus(null);
		m_CurrentTier.AbortTier();
	}

	public function PreviousTier()
	{
		ULog.Info("BaseMission.PreviousTier()");
		Selection.setFocus(null);
		m_PrevTier = true;
		m_CurrentTier.AbortTier();
	}

	// Custom event fires when mission is complete
	public function onMissionComplete()
	{
	}

	public function MessageBox(message:String)
	{
		var dialogIF = new com.GameInterface.DialogIF(message, _global.Enums.StandardButtons.e_ButtonsOk, "Message" );
//		dialogIF.SignalSelectedAS.Connect( null, SlotSelectedAS, this )
		dialogIF.Go( 4 );   // <-  4 is userdata.
	}

	// Convert scripted mission to XML
	public function ConvertToXML()
	{
		this.ScriptMission();
		
		var missionXML:String = '<?xml version="1.0"?>\n<mission title = "' + m_MissionTitle + '">\n';
		for (var i = 0; i < m_Tiers.length; i++) {
			missionXML += m_Tiers[i].ConvertToXML();
		}
		missionXML += '</mission>';

/*		var xml:XML = new XML();
		var mission:XMLNode = xml.createElement("mission");
		mission.attributes.title = m_MissionTitle;
		for (var i = 0; i < m_Tiers.length; i++) {
			mission.appendChild(m_Tiers[i].ConvertToXML(xml));
		}
		xml.appendChild(mission);
		// Escape/preserve carriage returns
		var xmlText = xml.toString().split("\n").join("\\n"); */
		// Stored in prefs2.xml file.  Only way I could find to get data out of game.
		DistributedValue.SetDValue("ug_mission_xml",missionXML);
		this.MessageBox(missionXML);
	}

}