// Kill Enemies Tier
// Completes when specified number of enemies is killed
// Enemy kill is a match if the full name of the enemy is contained in the specified string
// Example: tier.SetKillTarget("Ravenous Horde,Returned Townie,Alerted Zombie", 12) 
// Killing any one of Ravenous Horde,Returned Townie,Alerted Zombie counts toward dozen kills
import com.GameInterface.Game.Character;
import com.Utils.ID32;

class KillTier extends BaseTier
{
	
	public var m_TargetName:String;
	public var m_TargetKills:Number;
	public var m_CurrentKills:Number;
	public var m_KilledTargets:Array;

	public function KillTier()
	{
		m_KilledTargets = new Array();
	}

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("KillTier.LoadXML()");
		this.SetKillTarget(tierNode.attributes.targetName, Number(tierNode.attributes.targetKills));
	}

	public function SetKillTarget(targetName:String, targetKills:Number)
	{
		//ULog.Info("KillTier.SetKillTarget(): targetName=" + targetName + " targetKills=" + targetKills.toString());
		// targetName should contain full names of all enemies that qualify as a kill
		m_TargetName = targetName;
		m_TargetKills = targetKills;
		m_CurrentKills = 0;
		this.UpdateProgress();
	}

	public function StartTier()
	{
		ULog.Info("KillTier.StartTier(): m_TargetName=" + m_TargetName + " m_TargetKills=" + m_TargetKills.toString());
		com.Utils.GlobalSignal.SignalDamageNumberInfo.Connect( SlotDamageInfo, this );
	}

	function SlotDamageInfo( statID:Number, damage:Number, absorb:Number, attackResultType:Number, attackType:Number,  attackOffensiveLevel:Number, attackDefensiveLevel:Number, context:Number, targetID:ID32, iconID:ID32, iconColorLine:Number, combatLogFeedbackType:Number )
	{
		var targetCharacter:Character = Character.GetCharacter(targetID);
		if (targetCharacter != undefined) {
			if (targetCharacter.IsDead()) {
				var currentName = targetCharacter.GetName().toLowerCase();
				var targetName = m_TargetName.toLowerCase();
				if (targetName.indexOf(currentName) >= 0) {
					// Multiple damage numbers can come in for a target, making it look like multiple targets were killed
					// Keep track of which targets were killed, so they only count once
					var previousKill = false;
					// Start at end of array, because latest kills at the bottom
//					_global.m_MissionDebugWindow.contentTextField.text = m_KilledTargets.length.toString() + " Array\n" + _global.m_MissionDebugWindow.contentTextField.text;
					for(var i = m_KilledTargets.length - 1; i >= 0; i--){
						if(m_KilledTargets[i] == targetID.toString()){
							previousKill = true;
							//_global.m_MissionDebugWindow.contentTextField.text = m_KilledTargets[i].toString() + " Previous\n" + _global.m_MissionDebugWindow.contentTextField.text;
							break;
						}
					}
					if (previousKill == false) {
						//_global.m_MissionDebugWindow.contentTextField.text = targetID.toString() + "\n" + _global.m_MissionDebugWindow.contentTextField.text;
						m_CurrentKills++;
						m_KilledTargets.push(targetID.toString());
						this.UpdateProgress();
						if (m_CurrentKills >= m_TargetKills) {
							com.Utils.GlobalSignal.SignalDamageNumberInfo.Disconnect( SlotDamageInfo, this );
							this.EndTier();
						}
					}
				}
			}
		}
	}
	
	function UpdateProgress()
	{
		m_TierProgress = "(" + m_CurrentKills.toString() + "/" + m_TargetKills.toString() + ")";
		ULog.Info("KillTier.UpdateProgress(): " + m_TierProgress);
		this.onTierProgress();
	}

	public function AbortTier()
	{
		ULog.Info("KillTier.AbortTier()");
		com.Utils.GlobalSignal.SignalDamageNumberInfo.Disconnect( SlotDamageInfo, this );
		this.EndTier();
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'targetName="' + m_TargetName + '" '
			+ 'targetKills="' + m_TargetKills.toString() + '" '
			+ '/>\n'
		return tierXML;
	}

}
