// Select and return character objects for use in other programs
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.Utils.ID32;
import mx.data.types.Int;

class Selector
{
	
	private var m_PlayField:Number;
	private var m_X:Number;
	private var m_Y:Number;
	private var m_Z:Number;
	private var m_Distance:Number;	// distance from X,Z
	private var m_yDistance:Number;	// distance from Y
	private var m_Gender:Number;

	public function Selector() 
	{
		
	}
	
	// If set, objects must be at the specified location
	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number, waypointName:String)
	{
		//ULog.Info("Selector.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;
		m_yDistance = yDistance;
	}
	
	// Not used: API doesn't return gender of NPC
	// If specified, character must be the specified gender
/*	public function SetGender(gender:String)
	{
		gender = gender.toLowerCase();
		if (gender == "male") {
			m_Gender = _global.Enums.BreedSex.e_Sex_Male;
		} else {
			m_Gender = _global.Enums.BreedSex.e_Sex_Female;
		}
	}
*/
	
	// Select player character
	public function SelectPlayer() : Character
	{
		var player:Character = Character.GetClientCharacter();
		return player;
	}
	
	// Select friendly target
	public function SelectFriendlyTarget() : Character
	{
		var player:Character = this.SelectPlayer();
		var targetID:ID32 = player.GetDefensiveTarget();
		var target:Character = Character.GetCharacter(targetID);
		return target;
	}
	
	// Select enemy target
	public function SelectEnemyTarget() : Character
	{
		var player:Character = this.SelectPlayer();
		var targetID:ID32 = player.GetOffensiveTarget();
		var target:Character = Character.GetCharacter(targetID);
		return target;
	}
	
	// Select a single NPC by name
	public function SelectNPC(npcNames:String) : Character
	{
		var npc:Character;
		// Call SelectNPCs() and get first object from collection
		var npcs:Object = this.SelectNPCs(npcNames, 1);
		for (var prop in npcs) {
			npc = npcs[prop];
			break;
		}
		return npc;
	}
	
	// Select NPCs by name
	public function SelectNPCs(npcNames:String, qty:Number) : Object
	{
		var npcs:Object = new Object();
		if (qty == undefined || qty == NaN || qty < 1) {
			qty = 1;
		}
		
		// Split names into array and make lower case
		var names:Array = npcNames.split(",");
		for (var i:Number = 0; i < names.length; i++)
		{
			names[i] = names[i].toLowerCase();
		}
		
		// Search nearby Dynels for NPCs
		ULog.Info("SelectNPCS -- qty: " + qty + " npcNames: " + npcNames);
		var qtyFound = 0;
		var nearDynels:Object = _root.interactioncontroller.m_InteractionDynels;
		var npc:Character;
		var npcName:String;
		for (var prop in nearDynels) {
			ULog.Info("SelectNPCS -- DynelName: " + nearDynels[prop].GetName());
			npc = Character.GetCharacter(nearDynels[prop].GetID());
			npcName = npc.GetName().toLowerCase();
			ULog.Info("SelectNPCS -- npcName: " + npcName);
			for (var i:Number = 0; i < names.length; i++)
			{
				if (names[i] == "*" || npcName == names[i]) {
					ULog.Info("SelectNPCS -- Name Match");
					if (this.CheckLocation(npc) == true) {
						npcs[prop] = npc;
						qtyFound++;
						break;
					}
				}
			}
			// If quantity met, stop searching
			if (qtyFound >= qty)
			{
				break;
			}
		}
		
		ULog.Info("SelectNPCS -- qtyFound: " + qtyFound);
		ULog.Info("SelectNPCS -- npcs: " + npcs);
		return npcs;
	}
	
	// Check if object is within specified location
	public function CheckLocation(dynel:Dynel) : Boolean
	{
		// If no location set, return
		_root.fifo.SlotShowFIFOMessage("m_PlayField: " + m_PlayField);
		if (m_PlayField == undefined || m_PlayField == NaN)
		{
			return true;
		}
		
		// Check if object is in correct playfield and location
		var inLocation = false;
		var currentField = dynel.GetPlayfieldID();
		_root.fifo.SlotShowFIFOMessage("currentField: " + currentField);
		if (currentField == m_PlayField) {
			var position = dynel.GetPosition();
			var currentX = position.x;
			var currentY = position.y;
			var currentZ = position.z;
			var xDist = Math.abs(currentX - m_X);
			var yDist = Math.abs(currentY - m_Y);
			var zDist = Math.abs(currentZ - m_Z);

			// See if we are in range of coordinates
			if (Math.abs(currentX - m_X) <= m_Distance && Math.abs(currentZ - m_Z) <= m_Distance && Math.abs(currentY - m_Y) <= m_yDistance) {
				inLocation = true;
			}
		}
		_root.fifo.SlotShowFIFOMessage("inLocation: " + inLocation);
		return inLocation;
	}
	
	// Not Used: API doesn't return gender for NPCs
	// Check if character is specified gender
/*	public function CheckGender(character:Character) : Boolean
	{
		if (m_Gender == undefined)
		{
			return true;
		}
		
		var sex_YesPlease:Number = character.GetStat(_global.Enums.Stat.e_Sex);
		ULog.Info("CheckGender -- sex_YesPlease=" + sex_YesPlease + " m_Gender=" + m_Gender);
		if (sex_YesPlease == m_Gender) {
			return true;
		} else {
			return false;
		}
	}
*/
	
}