// Cinematic Tier
// Subclass of Dialog Tier that allows camera control synchronized with dialog.
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.Game.Camera;
import com.GameInterface.DistributedValue;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.AccountManagement;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.TargetingInterface;
import com.Utils.Interpolator;
import mx.transitions.easing.*;

class CinematicTier extends DialogTier
{
	public var m_CurrentPos:Vector3;
	public var m_CurrentTarget:Vector3;
	public var m_NewPos:Vector3;
	public var m_NewTarget:Vector3;
	public var m_CameraNo:Number;
	public var m_Playfield;
	public var m_CurrentField;
	public var m_ResetLooks:Boolean;
	//public var m_CharacterCreationIF;
	public var m_TargetCharacter;
	public var m_IntPosX:Interpolator;
	public var m_IntPosY:Interpolator;
	public var m_IntPosZ:Interpolator;
	public var m_IntTargetX:Interpolator;
	public var m_IntTargetY:Interpolator;
	public var m_IntTargetZ:Interpolator;
	
	public function CinematicTier()
	{
		m_Cinematic = true;
		m_CurrentPos = new Vector3(0, 0, 0);
		m_CurrentTarget = new Vector3(0, 0, 0);
		m_NewPos = new Vector3(0, 0, 0);
		m_NewTarget = new Vector3(0, 0, 0);
	}

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("CinematicTier.LoadXML()");
		this.SetPlayfield(Number(tierNode.attributes.playField));
		if (tierNode.attributes.speed) {
			this.m_WordsPerSec = Number(tierNode.attributes.speed);
		}
		if (tierNode.attributes.contAudio) {
			m_ContAudio = Boolean(tierNode.attributes.contAudio);
		}
		for (var i = 0; i < tierNode.childNodes.length; i++) {
			var cinematicNode:XMLNode = tierNode.childNodes[i];
			if (cinematicNode) {
				var cinematicFaction = cinematicNode.attributes.faction;
				var cinematicGender = cinematicNode.attributes.gender;
				// Check faction and gender requirements
				if ((cinematicFaction == undefined || cinematicFaction == "" || cinematicFaction.toLowerCase() == m_Player.m_Faction.toLowerCase()) &&
					(cinematicGender == undefined || cinematicGender == "" || cinematicGender.toLowerCase() == m_Player.m_Gender.toLowerCase()))
				{					
					var cinematicLine;
					switch (cinematicNode.attributes.type) {
					case "camera" :
						this.AddCameraPath(Number(cinematicNode.attributes.duration), Number(cinematicNode.attributes.posX), Number(cinematicNode.attributes.posY), 
										   Number(cinematicNode.attributes.posZ), Number(cinematicNode.attributes.targetX), Number(cinematicNode.attributes.targetY), 
										   Number(cinematicNode.attributes.targetZ), cinematicNode.attributes.ease);
						break;
					// Removed from TSW API. No longer functions.
					case "playerpos" :
						//this.AddPlayerPosition(Number(cinematicNode.attributes.x), Number(cinematicNode.attributes.y), Number(cinematicNode.attributes.z), 
						//					   Number(cinematicNode.attributes.rotation));
						break;
					// Removed from TSW API. No longer functions.
					case "targetpos" :
						//this.AddTargetPosition(Number(cinematicNode.attributes.x), Number(cinematicNode.attributes.y), Number(cinematicNode.attributes.z), 
						//					   Number(cinematicNode.attributes.rotation));
						break;
					// Removed from TSW API. No longer functions.
					case "npcpos" :
						//this.AddNPCPosition(cinematicNode.attributes.name, Number(cinematicNode.attributes.x), Number(cinematicNode.attributes.y), 
						//					Number(cinematicNode.attributes.z), Number(cinematicNode.attributes.rotation));
						break;
					case "facecoords" :
						this.AddFaceCoords(Number(cinematicNode.attributes.x), Number(cinematicNode.attributes.z));
						break;
					case "facetarget" :
						this.AddFaceTarget();
						break;
					case "facenpc" :
						this.AddFaceNPC(cinematicNode.attributes.name);
						break;
					case "fadeout" :
						cinematicLine = "#fadeout#";
						this.AddLine(cinematicLine, Number(cinematicNode.attributes.duration));
						break;
					case "fadein" :
						cinematicLine = "#fadein#";
						this.AddLine(cinematicLine, Number(cinematicNode.attributes.duration));
						break;
					case "dialog" :
						cinematicLine = cinematicNode.attributes.line;
						this.AddLine(cinematicLine, Number(cinematicNode.attributes.duration));
						break;
					case "audio" :
						this.AddAudio(cinematicNode.attributes.url, Boolean(cinematicNode.attributes.preload), Number(cinematicNode.attributes.volume), 
							Boolean(cinematicNode.attributes.loop), Boolean(cinematicNode.attributes.stop), Boolean(cinematicNode.attributes.muteMusic));
						break;
					case "looks" :
						this.AddLooks(cinematicNode);
						break;
					case "animation" :
						this.AddAnimations(cinematicNode);
						break;
					}
				}
			}
		}
		// If player looks changed, automatically add tier to reset them after cinematic
		// Otherwise, player will have a mix of applied looks with their own looks
		if (m_ResetLooks == true) {
			var resetlooksTier:LooksTier = m_Mission.AddTier("looks", "Reset player looks after cinematic");
			resetlooksTier.SetTarget("player", 1, true, false, false, 100);
		}
	}
	
	// Set Playfield. Camera paths will only be run in selected playfield. Otherwise, only dialog will play
	public function SetPlayfield(playField) {
		//ULog.Info("CinematicTier.SetPlayfield(): playField " + playField.toString());
		m_Playfield = playField;
	}

	// Add camera path
	public function AddCameraPath(duration:Number, posX:Number, posY:Number, posZ:Number, targetX:Number, targetY:Number, targetZ:Number, ease:String)
	{
		m_Dialog.push(["#camera#", duration, posX, posY, posZ, targetX, targetY, targetZ, ease]);
		// If using player coordinates (-99), need to position camera twice with slight delay between to center on player
		if (duration == 0 && (posX == -99 || targetX == -99)) {
			this.AddLine("", .01);
			m_Dialog.push(["#camera#", duration, posX, posY, posZ, targetX, targetY, targetZ, ease]);
		}
	}
	
	// Removed from TSW API. No longer functions.
/*	// Set player position and rotation in cinematic
	public function AddPlayerPosition(x, y, z, rotation) {
		m_Dialog.push(["#playerpos#", x, y, z, rotation]);
	}
	
	// Set current defensive target position and rotation in cinematic
	public function AddTargetPosition(x, y, z, rotation) {
		m_Dialog.push(["#targetpos#", x, y, z, rotation]);
	}
	
	// Set named NPC position and rotation in cinematic
	public function AddNPCPosition(name, x, y, z, rotation) {
		m_Dialog.push(["#npcpos#", name, x, y, z, rotation]);
	}
*/	
	// Set player rotation to face coordinates
	public function AddFaceCoords(x, z) {
		m_Dialog.push(["#facecoords#", x, z]);
	}
	
	// Set player to face target
	public function AddFaceTarget() {
		m_Dialog.push(["#facetarget#"]);
	}
	
	// Set player to face named NPC
	public function AddFaceNPC(name) {
		m_Dialog.push(["#facenpc#", name]);
	}
	
	// Add looks package
	public function AddLooks(looksNode:XMLNode) 
	{
		var looksTier:LooksTier = new LooksTier();
		looksTier.LoadXML(looksNode);
		m_Dialog.push(["#looks#", looksTier]);
		// If player looks changed, automatically add tier to reset them after cinematic
		// Otherwise, player will have a mix of applied looks with their own looks
		if (looksTier.m_LooksTarget == "player") {
			m_ResetLooks = true;
		}
	}
		
	// Add animations
	public function AddAnimations(animNode:XMLNode) 
	{
		var animTier:AnimationTier = new AnimationTier();
		animTier.LoadXML(animNode);
		m_Dialog.push(["#animation#", animTier]);
	}
		
	public function StartTier()
	{
		ULog.Info("CinematicTier.StartTier()");
		// Press Esc to exit cinematic
		// You have to use entire public path to abort function
		//var abortFunction = "_root.untold\\untold.m_MissionListWindow.m_Content.m_CurrentMission.m_CurrentTier.AbortTier";
		var abortFunction = "_root.untold\\untold.m_CurrentTier.AbortTier";
		com.GameInterface.Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_ESC, abortFunction, _global.Enums.Hotkey.eHotkeyDown, 0);

		// If not in correct playField, don't hide UI
		m_CurrentField = m_Player.m_Character.GetPlayfieldID();
		if (m_CurrentField == m_Playfield) {
			DistributedValue.SetDValue("CharacterCreationActive", true);	
			//m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
			var selector:Selector = new Selector();
			m_TargetCharacter = selector.SelectFriendlyTarget();
			//var targetID = m_Player.m_Character.GetDefensiveTarget();
			//m_TargetCharacter = Character.GetCharacter(targetID);
			// Untarget so green circle doesn't show in cinematic
			TargetingInterface.SetTarget(null);
		} else {
			ULog.Info("CinematicTier.StartTier(): Not in playfield");
		}
		m_TierEnded = false;
		m_CurrentLineNo = -1;
		m_CameraNo = 0;
		this.ProcessDialog();
	}
	
	public function AbortTier()
	{
		ULog.Info("CinematicTier.AbortTier()");
		m_CurrentLineNo = m_Dialog.length;
		_root.ugFade.SlotFadeScreen( true, 0);
		this.EndTier();
	}
	
	// Process camera paths
	public function ProcessDialog()
	{
		//_global.m_MissionDebugWindow.contentTextField.text += "\nProcessDialog()";
		// If logging out, end tier
		if (AccountManagement.GetInstance().GetLoginState() <> _global.Enums.LoginState.e_LoginStateInPlay) {
			this.EndTier();
			return;
		}
		
		var currentLine = m_Dialog[m_CurrentLineNo + 1];
		switch (currentLine[0]) {
		case "#camera#" :
			m_CurrentLineNo++;
			m_CameraNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			var duration = currentLine[1];
			
			if (currentLine[2] == -99) {
				m_NewPos = m_Player.m_Character.GetPosition();
				// Slightly adjust to center camera on player face
				// Adjustment is affected by camera angle
				// Not perfect, but much better than default camera
				var deltax = m_NewPos.x - m_CurrentPos.x;
				var deltaz = m_NewPos.z - m_CurrentPos.z;
				var xangle = (Math.atan2(deltax, deltaz));
				var zangle = (Math.atan2(deltaz, deltax));
				var xadj = (Math.PI / 2 - Math.abs(xangle)) / (Math.PI / 2) * .3;
				var zadj = (Math.PI / 2 - Math.abs(zangle)) / (Math.PI / 2) * .3;
				m_NewPos.x -= xadj;
				m_NewPos.y -= .3;
				m_NewPos.z += zadj;
				ULog.Info("Position Camera: xadj = " + xadj + " xangle = " + xangle + " degrees = " + xangle * (180/Math.PI) + " new.x = " + m_NewPos.x) ;
				ULog.Info("Position Camera: zadj = " + zadj + " zangle = " + zangle + " degrees = " + zangle * (180/Math.PI) + " new.z = " + m_NewPos.z) ;
			}
			else {
				m_NewPos.x = currentLine[2];
				m_NewPos.y = currentLine[3];
				m_NewPos.z = currentLine[4];
			}			
			// If no new target coordinates, keep current target
			if (currentLine[5]) {
				// targetX -99 means player position is target
				if (currentLine[5] == -99) {
					m_NewTarget = m_Player.m_Character.GetPosition();
					// Slightly adjust to center camera on player face
					var deltax = m_NewTarget.x - m_CurrentPos.x;
					var deltaz = m_NewTarget.z - m_CurrentPos.z;
					var xangle = (Math.atan2(deltax, deltaz));
					var zangle = (Math.atan2(deltaz, deltax));
					var xadj = (Math.PI / 2 - Math.abs(xangle)) / (Math.PI / 2) * .3;
					var zadj = (Math.PI / 2 - Math.abs(zangle)) / (Math.PI / 2) * .3;
					m_NewTarget.x -= xadj;
					m_NewTarget.y -= .3;
					m_NewTarget.z += zadj;
					ULog.Info("Target Camera: xadj = " + xadj + " xangle = " + xangle + " degrees = " + xangle * (180/Math.PI) + " new.x = " + m_NewTarget.x) ;
					ULog.Info("Target Camera: zadj = " + zadj + " zangle = " + zangle + " degrees = " + zangle * (180/Math.PI) + " new.z = " + m_NewTarget.z) ;
				}
				else {
					m_NewTarget.x = currentLine[5];
					m_NewTarget.y = currentLine[6];
					m_NewTarget.z = currentLine[7];
				}
			}
			else {
				m_NewTarget = m_CurrentTarget;
			}
			
			//Ease function
			var ease:String = currentLine[8];
			var easeFunc;
			if (ease) {
				var easeType;
				var easeArray:Array = ease.split(".");
				//_root.fifo.SlotShowFIFOMessage(ease + " : " + easeArray[0].toLowerCase() + " : " + easeArray[1].toLowerCase(), 0);
				// Ease type/category
				switch (easeArray[0].toLowerCase()) {
				case "regular" :
					easeType = Regular;
					break;
				case "strong" :
					easeType = Strong;
					break;
				case "back" :
					easeType = Back;
					break;
				case "elastic" :
					easeType = Elastic;
					break;
				case "bounce" :
					easeType = Bounce;
					break;
				default :
					easeType = undefined;
					break;
				}
				// Ease function
				switch (easeArray[1].toLowerCase()) {
				case "easein" :
					easeFunc = easeType.easeIn;
					break;
				case "easeinout" :
					easeFunc = easeType.easeInOut;
					break;
				case "easeout" :
					easeFunc = easeType.easeOut;
					break;
				default :
					easeFunc = undefined;
					break;
				}
				
			}
			
			// Start interpolator. Adjusts position regardless of framerate
			duration = duration/1000; // Interpolator uses seconds
			m_IntPosX = new Interpolator();
			m_IntPosY = new Interpolator();
			m_IntPosZ = new Interpolator();
			m_IntTargetX = new Interpolator();
			m_IntTargetY = new Interpolator();
			m_IntTargetZ = new Interpolator();
			m_IntPosX.Start(duration, m_CurrentPos.x, m_NewPos.x, easeFunc);
			m_IntPosY.Start(duration, m_CurrentPos.y, m_NewPos.y, easeFunc);
			m_IntPosZ.Start(duration, m_CurrentPos.z, m_NewPos.z, easeFunc);
			m_IntTargetX.Start(duration, m_CurrentTarget.x, m_NewTarget.x, easeFunc);
			m_IntTargetY.Start(duration, m_CurrentTarget.y, m_NewTarget.y, easeFunc);
			m_IntTargetZ.Start(duration, m_CurrentTarget.z, m_NewTarget.z, easeFunc);

			this.MoveCamera(m_CameraNo);
			this.ProcessDialog();
			break;
		// Removed from TSW API. No longer functions.
/*		case "#playerpos#" :
			m_CurrentLineNo++;
			this.SetPlayerPosition(currentLine[1], currentLine[2], currentLine[3], currentLine[4]);
			this.ProcessDialog();
			break;
		case "#targetpos#" :
			m_CurrentLineNo++;
			this.SetTargetPosition(currentLine[1], currentLine[2], currentLine[3], currentLine[4]);
			this.ProcessDialog();
			break;
		case "#npcpos#" :
			m_CurrentLineNo++;
			this.SetNPCPosition(currentLine[1], currentLine[2], currentLine[3], currentLine[4], currentLine[5]);
			this.ProcessDialog();
			break;*/
		case "#facecoords#" :
			m_CurrentLineNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			this.FaceCoords(currentLine[1], currentLine[2]);
			this.ProcessDialog();
			break;
		case "#facetarget#" :
			m_CurrentLineNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			this.FaceCharacter(m_TargetCharacter);
			this.ProcessDialog();
			break;
		case "#facenpc#" :
			m_CurrentLineNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			this.FaceNPC(currentLine[1]);
			this.ProcessDialog();
			break;
		case "#looks#" :
			m_CurrentLineNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			this.ApplyLooks(currentLine[1]);
			this.ProcessDialog();
			break;
		case "#animation#" :
			m_CurrentLineNo++;
			// If not in correct playfield, show dialogue only
			if (m_CurrentField <> m_Playfield) {
				this.ProcessDialog();
				return;
			}
			this.ProcessAnimations(currentLine[1]);
			this.ProcessDialog();
			break;
		default :
			// Parent class handles dialog
			super.ProcessDialog();
			break;
		}
	}
	
	public function MoveCamera(cameraNo)
	{
		// If logging out, end tier
		if (AccountManagement.GetInstance().GetLoginState() <> _global.Enums.LoginState.e_LoginStateInPlay) {
			this.EndTier();
			return;
		}

		if (m_TierEnded == true || cameraNo <> m_CameraNo) {
			return;
		}

		if (m_CurrentPos.x != m_NewPos.x || m_CurrentPos.y != m_NewPos.y || m_CurrentPos.z != m_NewPos.z) {
			m_CurrentPos.x = m_IntPosX.GetCurrentValue();
			m_CurrentPos.y = m_IntPosY.GetCurrentValue();
			m_CurrentPos.z = m_IntPosZ.GetCurrentValue();
			m_CurrentTarget.x = m_IntTargetX.GetCurrentValue();
			m_CurrentTarget.y = m_IntTargetY.GetCurrentValue();
			m_CurrentTarget.z = m_IntTargetZ.GetCurrentValue();
			_global.setTimeout(this, "MoveCamera", 1, cameraNo);
		}
		else {
			m_CurrentPos.x = m_NewPos.x;
			m_CurrentPos.y = m_NewPos.y;
			m_CurrentPos.z = m_NewPos.z;
			m_CurrentTarget.x = m_NewTarget.x;
			m_CurrentTarget.y = m_NewTarget.y;
			m_CurrentTarget.z = m_NewTarget.z;
		}
		Camera.PlaceCamera(m_CurrentPos.x, m_CurrentPos.y, m_CurrentPos.z, m_CurrentTarget.x, m_CurrentTarget.y, m_CurrentTarget.z, 0, 1, 0);
	}

	function FaceCoords(x, z)
	{
		ULog.Info("CinematicTier.FaceCoords(): x=" + x.toString() + " z=" + z.toString());
		var MyPos = m_Player.m_Character.GetPosition( _global.Enums.AttractorPlace.e_Ground );
		var deltaz = z - MyPos.z;
		var deltax = x - MyPos.x;
		var angle = (Math.atan2(deltax, deltaz));
		// You have to create and release IF with each call, or Esc to abort won't work
		// Unfortunately, this causes slight delay
		var characterCreation = new com.GameInterface.CharacterCreation.CharacterCreation(true);
		characterCreation.SetRotation( angle );
		// Setting to null immediately can cause crash, so let object go out of scope normally.
		// characterCreation = null;
		// Delay rehiding UI, waiting for characterCreation to go out of scope.
		// Otherwise, UI will be visible during cinematic.
		_global.setTimeout(this, "HideUI", 100);
	}
	
	function HideUI()
	{
		// Rehide UI after releasing object
		DistributedValue.SetDValue("CharacterCreationActive", false);	
		DistributedValue.SetDValue("CharacterCreationActive", true);	
	}	
	
	function FaceCharacter(character)
	{
		if (character) {
			var charPos = character.GetPosition( _global.Enums.AttractorPlace.e_Ground );
			this.FaceCoords(charPos.x, charPos.z);
		}
	}
	
	function FaceNPC(name:String)
	{
		var selector:Selector = new Selector();
		var npc:Character = selector.SelectNPC(name);
		this.FaceCharacter(npc);
	}
	
	function ApplyLooks(looksTier:LooksTier)
	{
		looksTier.StartTier();
	}
	
	function ProcessAnimations(animTier:AnimationTier)
	{
		animTier.StartTier();
	}
	
	// SetPosition() was removed from TSW API, so none of these Position functions work
/*	function SetPlayerPosition(x, y, z, rotation) {
		this.SetPosition(m_Player.m_Character, x, y, z, rotation);
	}

	function SetTargetPosition(x, y, z, rotation) {
		if (m_TargetCharacter) {
			this.SetPosition(m_TargetCharacter, x, y, z, rotation);
		}
	}

	function SetNPCPosition(name, x, y, z, rotation) {
		// Search nearby dynels by name
		// Dynels in vicinity are in InteractionController collection
		var nearDynels = _root.interactioncontroller.m_InteractionDynels;
		for (var prop in nearDynels) {
			if (nearDynels[prop].GetName().toLowerCase() == name.toLowerCase()) {
				this.SetPosition(nearDynels[prop], x, y, z, rotation);
				break;
			}
		}
	}

	function SetPosition(character, x, y, z, rotation) {
		var position = new com.GameInterface.MathLib.Vector3();
		position.x = x;
		position.y = y - 1.900001525879;  // SetPosition moves feet to this height, so need to adjust
		position.z = z;
		character.SetPosition(position);
		if (rotation) {
			character.SetRotation(-rotation); // some reason it is negative of value from GetRotation(), maybe because camera is at back
		}
	}*/

	
	public function EndTier()
	{
		ULog.Info("CinematicTier.EndTier().");
		if (m_TierEnded == false) {
			//ULog.Info("CinematicTier.EndTier: Releasing Esc Hotkey");
			com.GameInterface.Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_ESC, "", _global.Enums.Hotkey.eHotkeyDown, 0);
			if (m_CurrentField == m_Playfield) {
				// Creating and releasing this object gives control camera back to player
				// Mysterious green glasses can sometimes appear on character after cinematics
				// Not sure why, but it seems to be most likely if your character is targeted and you cancel the cinematic with Esc
				// Nothing I tried prevents it, but hopefully it will be rare
				//ULog.Info("CinematicTier.EndTier: Creating characterCreationIF");
				var characterCreationIF:CharacterCreation = new com.GameInterface.CharacterCreation.CharacterCreation(true);
				//characterCreationIF.ResetSurgeryData();

				//ULog.Info("CinematicTier.EndTier: Set characterCreationIF null");
				// Setting to null immediately can cause crash, so let object go out of scope normally.
				// characterCreationIF = null;
				//ULog.Info("CinematicTier.EndTier: Set CharacterCreationActive false");
				DistributedValue.SetDValue("CharacterCreationActive", false);	
				//ULog.Info("CinematicTier.EndTier: Fade in");
				_root.ugFade.SlotFadeScreen( true, 0);
				// Retarget character
				//ULog.Info("CinematicTier.EndTier: Check m_TargetCharacter");
				if (m_TargetCharacter) {
					//ULog.Info("CinematicTier.EndTier: Reset target");
					TargetingInterface.SetTarget(m_TargetCharacter.GetID()); }

				// Reset looks to original character (see LooksTier.ResetLooks() for more info)
				//var eyeColor = characterCreationIF.GetEyeColorIndex();
				//_root.fifo.SlotShowFIFOMessage("ResetLooks() EyeColor: " + eyeColor);
				//characterCreationIF.SetEyeColorIndex(1);
				//characterCreationIF.SetEyeColorIndex(0);
				//characterCreationIF.SetEyeColorIndex(eyeColor);
				//var looks:LooksTier = new LooksTier();
				//looks.ResetLooks();
			}

			//ULog.Info("CinematicTier.EndTier: Before super.EndTier()");
			//_global.setTimeout(super, "EndTier", 2000);
			super.EndTier();
			//ULog.Info("CinematicTier.EndTier: After super.EndTier()");
		}
	}
	
	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'playField="' + m_Playfield.toString() + '" ';
		if (m_WordsPerSec <> 3) {
			tierXML += 'speed="' + m_WordsPerSec.toString() + '" ';
		}
		tierXML += '>\n'
		for (var i = 0; i < m_Dialog.length; i++) {
			var currentLine = m_Dialog[i];
			switch (currentLine[0]) {
			case "#camera#" :
				tierXML += '\t\t<cinematic type="camera" ' 
					+ 'duration="' + currentLine[1].toString() + '" ' 
					+ 'posX="' + currentLine[2].toString() + '" ' 
					+ 'posY="' + currentLine[3].toString() + '" ' 
					+ 'posZ="' + currentLine[4].toString() + '" ' 
					+ 'targetX="' + currentLine[5].toString() + '" ' 
					+ 'targetY="' + currentLine[6].toString() + '" ' 
					+ 'targetZ="' + currentLine[7].toString() + '" ' 
					+ '/>\n';
				break;
			case "#playerpos#" :
				tierXML += '\t\t<cinematic type="playerpos" ' 
					+ 'x="' + currentLine[1].toString() + '" ' 
					+ 'y="' + currentLine[2].toString() + '" ' 
					+ 'z="' + currentLine[3].toString() + '" ' 
					+ 'rotation="' + currentLine[4].toString() + '" ' 
					+ '/>\n';
				break;
			case "#targetpos#" :
				tierXML += '\t\t<cinematic type="targetpos" ' 
					+ 'x="' + currentLine[1].toString() + '" ' 
					+ 'y="' + currentLine[2].toString() + '" ' 
					+ 'z="' + currentLine[3].toString() + '" ' 
					+ 'rotation="' + currentLine[4].toString() + '" ' 
					+ '/>\n';
				break;
			case "#npcpos#" :
				tierXML += '\t\t<cinematic type="npcpos" ' 
					+ 'name="' + currentLine[1] + '" ' 
					+ 'x="' + currentLine[2].toString() + '" ' 
					+ 'y="' + currentLine[3].toString() + '" ' 
					+ 'z="' + currentLine[4].toString() + '" ' 
					+ 'rotation="' + currentLine[5].toString() + '" ' 
					+ '/>\n';
				break;
			case "#fadeout#" :
				tierXML += '\t\t<cinematic type="fadeout" duration="' + currentLine[1].toString() + '" />\n';
				break;
			case "#fadein#" :
				tierXML += '\t\t<cinematic type="fadein" duration="' + currentLine[1].toString() + '" />\n';
				break;
			default :
				var line = currentLine[0].split('"').join("'"); // convert quotes to single quotes
				// Most lines don't have duration, so do manually after conversion
				tierXML += '\t\t<cinematic type="dialog" line="' + line.split("\n").join("\\n") + '" ';
				// If line is blank, then add duration
				if (line == "" || line.indexOf("-") == 0) {
					tierXML += 'duration="' + currentLine[1].toString() + '" ';
				}
				tierXML += '/>\n';
				break;
			}
		}
		tierXML += "\t</tier>\n"
		return tierXML;
	}
}