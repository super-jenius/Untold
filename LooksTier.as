// Add Looks Package to character or NPC
import com.GameInterface.Game.Character;
import com.GameInterface.CharacterCreation.CharacterCreation;

class LooksTier extends BaseTier
{
	
	public var m_Looks:Array;
	public var m_LooksTarget:String;
	public var m_TargetQty:Number;
	public var m_ResetLooks:Boolean;
	public var m_KeepLooks:Boolean;
	public var m_Invisible:Boolean;
	public var m_Delay:Number;
	public var m_PlayField:Number;
	public var m_X:Number;
	public var m_Y:Number;
	public var m_Z:Number;
	public var m_Distance:Number;	// distance from X,Z
	public var m_yDistance:Number;	// distance from Y
	
	public function LooksTier()
	{
		m_SkipPrev = true;
		m_NoBell = true;
	}
	
	public function LoadXML(tierNode:XMLNode)
	{
		ULog.Info("LooksTier.LoadXML()");
		// Set targets
		this.SetTarget(tierNode.attributes.looksTarget, Number(tierNode.attributes.targetQty), Boolean(tierNode.attributes.resetLooks), 
						Boolean(tierNode.attributes.keepLooks), Boolean(tierNode.attributes.invisible), Number(tierNode.attributes.delay));
						
					
		//_root.fifo.SlotShowFIFOMessage("m_ResetLooks: " + m_ResetLooks);
		// If resetting looks on player, no need to load the rest
		if (m_ResetLooks == true) {
			//_root.fifo.SlotShowFIFOMessage("m_ResetLooks == true");
			return;
		}
		
		// Set location for NPCs to target
		this.SetLocation(Number(tierNode.attributes.playField), Number(tierNode.attributes.x), Number(tierNode.attributes.y), Number(tierNode.attributes.z), 
						Number(tierNode.attributes.distance), Number(tierNode.attributes.yDistance));
		
		// Add invisible look package. Makes model invisible before applying other looks.
		if (m_Invisible == true) {
			this.AddLooks("7752815", "Invisible");
		}
		
		// Add looks packages 
		// RDBIDs will be looked up in LooksRDB.xml
		// This works, but looking up IDs adds too much to mission load time.
		//var looksXML:XML = _root["untold\\untold"].m_LooksRDBXML;
		for (var i = 0; i < tierNode.childNodes.length; i++) {
			var looksNode:XMLNode = tierNode.childNodes[i];
			if (looksNode) {
				var rdbID:String = looksNode.attributes.rdbid;
				var description:String = looksNode.attributes.description;
				var remove:Boolean = Boolean(looksNode.attributes.removeLooks);
                		var configuration:String = looksNode.attributes.configuration;
				//if (rdbID == undefined) {
					//// Lookup RDBID in XML file based on description
					//var query = "VFPData/looksrdb[@desc='" + description + "']";
					//var xmlNode:XMLNode = XPathAPI.selectSingleNode(looksXML.firstChild, query);
					//rdbID = xmlNode.attributes.rdbid;
				//}
				this.AddLooks(rdbID, description, remove, configuration);
			}
		}
		ULog.Info("LooksTier.LoadXML(): Complete");
	}
	
	public function SetTarget(looksTarget:String, targetQty:Number, resetLooks:Boolean, keepLooks:Boolean, invisible:Boolean, delay:Number)
	{
		m_LooksTarget = looksTarget.toLowerCase();
		m_TargetQty = targetQty;
		m_ResetLooks = resetLooks;
		m_KeepLooks = keepLooks;
		m_Invisible = invisible;
		m_Delay = isNaN(delay) ? 0 : delay
	}
	
	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number)
	{
		//ULog.Info("LooksTier.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;
		m_yDistance = yDistance;
	}
	
	public function AddLooks(looksPackageRDBID:String, description:String, removeLooks:Boolean, looksConfiguration:String) 
	{
		if (m_Looks == undefined) {
			m_Looks = new Array();
		}
		m_Looks.push([Number(looksPackageRDBID), description, removeLooks, Number(looksConfiguration)]);	
	}
	
	public function StartTier()
	{
		ULog.Info("LooksTier.StartTier()");
		if (m_ResetLooks == true) {
			//this.ResetLooks();
			_global.setTimeout(this, "ResetLooks", m_Delay);
		} else {
			//this.ApplyLooks();
			_global.setTimeout(this, "ApplyLooks", m_Delay);
		}

		// End tier as soon as looks are applied
		this.EndTier();
	}
	
	private function ApplyLooks()
	{
		ULog.Info("LooksTier.ApplyLooks()");
		var looksTargets:Object = new Object();
		var selector:Selector = new Selector();
		ULog.Info("LooksTier.ApplyLooks() m_LooksTarget: " + m_LooksTarget);
		switch (m_LooksTarget) 
		{
		case undefined:
			break;
		case "player" :
			looksTargets["player"] = selector.SelectPlayer();
			break;
		case "target" :
			looksTargets["target"] = selector.SelectFriendlyTarget();
			break;
		default :
			selector.SetLocation(m_PlayField, m_X, m_Y, m_Z, m_Distance, m_yDistance);
			looksTargets = selector.SelectNPCs(m_LooksTarget, m_TargetQty);
			break;
		}
		if (looksTargets != undefined) {
			//_root.fifo.SlotShowFIFOMessage("Targets found: " + m_LooksTarget + " " + looksTargets);
			var target:Character;
			for (var prop in looksTargets) {
				target = looksTargets[prop];
				if (m_KeepLooks != true) {
					target.RemoveAllLooksPackages();
				}
				for (var i = 0; i < m_Looks.length; i++) {
					var currentLooks = m_Looks[i];
					ULog.Info("LooksTier.ApplyLooks(): target=" + target.GetName() + " rdbid= " + currentLooks[0] + " desc=" + currentLooks[1] + " remove=" + currentLooks[2] + " configuration=" + currentLooks[3]);
					if (currentLooks[2] == true) {
						target.RemoveLooksPackage(currentLooks[0]);
					} else {
						target.AddLooksPackage(currentLooks[0], currentLooks[3]);
					}
				}
			}
		}
	}
	
	public function ResetLooks()
	{
		ULog.Info("LooksTier.ResetLooks()");
		//_root.fifo.SlotShowFIFOMessage("ResetLooks()");
		// To reset player looks, you have to remove all current looks first, change something in their appearance.  
		// 	then change it back to the original value
		m_Player.m_Character.RemoveAllLooksPackages();
		ULog.Info("LooksTier.ResetLooks(): RemoveAllPackages");
		var characterCreationIF:CharacterCreation = new com.GameInterface.CharacterCreation.CharacterCreation(true);
		ULog.Info("LooksTier.ResetLooks(): Slotting Signals");
		characterCreationIF.SignalCreateCharacterFailed.Connect(SlotCCFailed, this);
		characterCreationIF.SignalCreateCharacterSucceded.Connect(SlotCCSuccess, this);
		characterCreationIF.SignalClothingChanged.Connect(SlotCC, this);
		// Eye color is the least noticable change. 
		// Change eye color twice to make sure it is actually different from the player's current eye color.
		// Otherwise, it may not register as a change, and player won't get original looks back.
		var eyeColor = characterCreationIF.GetEyeColorIndex();
		//_root.fifo.SlotShowFIFOMessage("ResetLooks() EyeColor: " + eyeColor);
		characterCreationIF.SetEyeColorIndex(1);
		characterCreationIF.SetEyeColorIndex(0);
		characterCreationIF.SetEyeColorIndex(eyeColor);
		//ULog.Info("LooksTier.ResetLooks(): delete characterCreationIF");		
		//delete characterCreationIF;
		ULog.Info("LooksTier.ResetLooks() End");		
	}
	
	public function SlotCCFailed()
	{
		ULog.Info("LooksTier.SlotCCFailed()");
	}
	public function SlotCCSuccess()
	{
		ULog.Info("LooksTier.SlotCCSuccess()");
	}
	public function SlotCC()
	{
		ULog.Info("LooksTier.SlotCC()");
	}

		
}
