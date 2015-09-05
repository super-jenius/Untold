// Target Tier
// Completes when specified target is selected
// Supports offensive and defensive targets
import com.Utils.ID32;
import com.GameInterface.Game.Character;

class TargetTier extends BaseTier
{
	public var m_TargetName:String;
	public var m_IsOffensiveTarget:Boolean;

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("TargetTier.LoadXML()");
		this.SetTarget(tierNode.attributes.targetName, (tierNode.attributes.isOffensiveTarget == "true"));
	}

	public function SetTarget(targetName:String, isOffensiveTarget:Boolean)
	{
		//ULog.Info("TargetTier.LoadXML(): targetName=" + targetName + " isOffensiveTarget=" + isOffensiveTarget.toString());
		m_TargetName = targetName;
		m_IsOffensiveTarget = isOffensiveTarget;
	}
	
	private function CheckTarget(targetID:ID32)
	{
		// Uncomment line below to put target name in chat.  Useful for German/French translation.
		//com.GameInterface.Chat.SetChatInput(Character.GetCharacter(targetID).GetName());
		if (Character.GetCharacter(targetID).GetName().toLowerCase() == m_TargetName.toLowerCase()) {
			// Target selected. End Tier.
			ULog.Info("TargetTier.CheckTarget(): Target selected");
			this.EndTier();
		}
	}
	
	public function StartTier()
	{
		ULog.Info("TargetTier.StartTier(): m_TargetName=" + m_TargetName + " m_IsOffensiveTarget=" + m_IsOffensiveTarget.toString());
		if (m_IsOffensiveTarget == true) {
			m_Player.m_Character.SignalOffensiveTargetChanged.Connect(SlotTargetChanged, this);
			// Check if target already selected.
			this.CheckTarget(m_Player.m_Character.GetOffensiveTarget());
			//this.MessageBox("Offensive Slot Set");
		} else {
			m_Player.m_Character.SignalDefensiveTargetChanged.Connect(SlotTargetChanged, this);
			// Check if target already selected.
			this.CheckTarget(m_Player.m_Character.GetDefensiveTarget());
			//this.MessageBox("Defensive Slot Set");
		}
	}
	
	public function SlotTargetChanged(targetID:ID32)
	{

		//this.MessageBox("Target Changed");
		this.CheckTarget(targetID);		
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'targetName="' + m_TargetName + '" isOffensiveTarget="' + m_IsOffensiveTarget.toString() + '" />\n'
		return tierXML;
	}

}