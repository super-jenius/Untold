// Player Info class
// Used in mission scripting and tiers
import com.GameInterface.Game.Character;
import com.Utils.ID32;

class PlayerInfo
{
	public var m_Character:Character;
	public var m_CharacterID:ID32;
	public var m_Name:String;
	public var m_Faction:String;
	public var m_Gender:String;
	
	public function PlayerInfo()
	{
		m_Character = Character.GetClientCharacter();
		m_CharacterID = m_Character.GetID();
		m_Name = m_Character.GetName();
		var sex_YesPlease:Number = m_Character.GetStat(_global.Enums.Stat.e_Sex);
		if (sex_YesPlease == _global.Enums.BreedSex.e_Sex_Male) {
			m_Gender = "male";
		} else {
			m_Gender = "female";
		}
		var factionID = m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction);
		switch (factionID) {
			case _global.Enums.Factions.e_FactionDragon :
				m_Faction = "Dragon";
				break;
			case _global.Enums.Factions.e_FactionIlluminati :
				m_Faction = "Illuminati";
				break;
			case _global.Enums.Factions.e_FactionTemplar :
				m_Faction = "Templar";
				break;
			default :
				m_Faction = "Other";
				break;
		}
	}
}
