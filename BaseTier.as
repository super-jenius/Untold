// Custom Mission Base Tier class
import com.GameInterface.Game.Character;
import com.GameInterface.Utils;

class BaseTier
{
	public var m_Player:PlayerInfo;
	public var m_TierType:String; // set by Mission.AddTier()
	public var m_TierDescription:String;  // set by CustomMission
	public var m_TierProgress:String = "";	// set in subclass when progress is tracked
	public var m_TierEnded;
	public var m_Mission:BaseMission; // reference to parent mission only available during LoadXML
	public var m_SkipPrev; // When set to true, tier will be skipped when previous is pressed
	public var m_NoBell; // When true, no bell will sound when tier is complete

	public function StartTier()
	{
		// Override in subclass
	}

	public function LoadXML(tierNode:XMLNode)
	{
		// Override in subclass
	}

	// Call in subclass when tier complete.
	public function EndTier()
	{
		// Make sure EndTier isn't called more than once, such as when aborted
		if (m_TierEnded == false)
		{
			ULog.Info("BaseTier.EndTier()");
			m_TierEnded = true;
			// Utils.PlayFeedbackSound("sfx/gui/gui_mission_get.wav");
			// Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
			this.onTierComplete();
		}
	}
	
	// Abort tier. Override in subclass if necessary.
	public function AbortTier()
	{
		ULog.Info("BaseTier.AbortTier()");
		this.EndTier();
	}

	// Custom event called in subclass when m_TierProgress is changed
	public function onTierProgress()
	{
		
	}
	
	// Custom event fires when tier is complete
	public function onTierComplete()
	{
		
	}
	
	public function MessageBox(message:String)
	{
		var dialogIF = new com.GameInterface.DialogIF(message, _global.Enums.StandardButtons.e_ButtonsOk, "Message" );
//		dialogIF.SignalSelectedAS.Connect( null, SlotSelectedAS, this )
		dialogIF.Go( 4 );   // <-  4 is userdata.
	}

	public function ConvertToXML(noCloseTag)
	{
		var tierXML:String = '\t<tier type="' + m_TierType + '" description="' + m_TierDescription.split("\n").join("\\n") + '" '
		if (noCloseTag <> true)	{
			tierXML += "/>\n";
		}
		// Subclass will add attributes and close tag
		return tierXML;
	}

}