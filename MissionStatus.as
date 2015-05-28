// Load/save mission status
import com.GameInterface.DistributedValue;

class MissionStatus
{

	public var m_Tier:Number;
	public var m_Status:String;
	public var m_StatusXML:XML;
	private var m_StatusNode:XMLNode

	public function LoadStatus()
	{
		ULog.Info("MissionStatus.LoadStatus()");
		var missionStatuses = DistributedValue.GetDValue("ug_missions");
		// Current status may be automatically copied to new character, so make sure character ID is the same
		var playerInfo = new PlayerInfo();
		//_global.m_MissionDebugWindow.contentTextField.text = "LoadStatus()\n" + _global.m_MissionDebugWindow.contentTextField.text;;
		if (missionStatuses == undefined || missionStatuses == "" || missionStatuses.toString().indexOf('characterID="' + playerInfo.m_CharacterID.toString() + '"') == -1) {
			ULog.Info("MissionStatus.LoadStatus(): Status reset");
			//_global.m_MissionDebugWindow.contentTextField.text = "Status reset.\n" + _global.m_MissionDebugWindow.contentTextField.text;;
			missionStatuses = '<?xml version="1.0"?><missions characterID="' + playerInfo.m_CharacterID.toString() + '" ></missions>';
//			missionStatuses = '<?xml version="1.0"?><missions><mission id="BasicTraining" tier="-99" /><mission id="APersonalMatter" tier="-1" /><mission id="TheScroll" tier="20" /></missions>';
		}
		m_StatusXML = new XML();
		m_StatusXML.ignoreWhite = true;
		m_StatusXML.parseXML(missionStatuses);
		m_StatusNode = undefined;	// reset
		
		return missionStatuses.toString();
	}
	
	public function LoadStatusNode(missionID:String)
	{
		if (m_StatusXML == undefined) {
			this.LoadStatus();
		}
		
		if (m_StatusNode.attributes.id.toLowerCase() <> missionID.toLowerCase()) {
			var statusListNode:XMLNode = m_StatusXML.firstChild;
			var statusNode:XMLNode;
			m_StatusNode = undefined;	// reset
			for (var i = 0; i < statusListNode.childNodes.length; i++) {
				statusNode = statusListNode.childNodes[i];
				if (statusNode.attributes.id.toLowerCase() == missionID.toLowerCase()) {
					m_StatusNode = statusNode;
					break;
				}
			}
			// If no status node found, create it
			if (m_StatusNode == undefined) {
				statusNode = m_StatusXML.createElement("mission");
				statusNode.attributes.id = missionID;
				statusNode.attributes.tier = -1;
				statusListNode.appendChild(statusNode);
				m_StatusNode = statusNode;
			}
		}		
	}
	
	// Get mission status
	public function GetStatus(missionID:String)
	{
		ULog.Info("MissionStatus.GetStatus(): missionID=" + missionID);
		this.LoadStatusNode(missionID);
		m_Tier = Number(m_StatusNode.attributes.tier);
		if (m_Tier == undefined) {
			m_Tier = -1;
		}
		switch (m_Tier) {
		case -99 :
			m_Status = "Complete";
			break;
		case -1 :
			m_Status = "";
			break;
		default :
			m_Status = "In Progress";
			break;
		}
	}
	
	// Set tier and save mission status
	public function SetTier(missionID:String, tier:Number)
	{
		ULog.Info("MissionStatus.SetTier(): missionID=" + missionID + " tier=" + tier.toString());
		if (m_StatusXML <> undefined) {
			this.LoadStatusNode(missionID);
			m_StatusNode.attributes.tier = tier;
			DistributedValue.SetDValue("ug_missions",m_StatusXML.toString());
			this.GetStatus(missionID);
		}
	}

	
}