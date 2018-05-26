// Testing Sandbox
import com.GameInterface.Game.Character;
import com.GameInterface.Chat
import com.GameInterface.DistributedValue;
import com.GameInterface.VicinitySystem;
import com.GameInterface.Game.Dynel;
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.Game.Camera;
import com.GameInterface.Waypoint;
import com.Utils.Point;
import flash.geom.Matrix;
import GUI.CharacterCreation.CameraController;
import Base64;
import GUI.Dialogue.DialogueWindow;
import GUIFramework.ClipNode;
import mx.utils.Base64Decoder;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Tooltip.*;
import com.GameInterface.SpellBase;
import flash.filters.DropShadowFilter;
import com.GameInterface.Browser.Browser;
import mx.xpath.XPathAPI;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Quests;
import com.GameInterface.DialogueBase;
import com.GameInterface.Nametags;

class Sandbox extends BaseMission
{

	public var m_Browser;
	public var m_Browser2;
	public var m_CamAdjust = 0;
	public var m_CharacterCreationIF:CharacterCreation;
	public var m_Dynel;
	public var m_UWIcon;
	public var m_WorldStory;
	public var m_WorldStory2;
	public var m_ClothingItem;
	public var m_LastTier:BaseTier;
	public var m_LastZoom;

	public function ScriptMission()
	{
		
		m_MissionTitle = "Sandbox";
		m_CurrentTierNo = -1;
		_global.m_MissionDebugWindow._visible = true;	
		
//		this.HackLocation();
//		this.ListDynels();

		//var tier_1 = this.AddTier("useitem", "Waiting.");
		//tier_1.SetItem("thereisnospoon");		


		//this.ErrorTest();
		//this.CharCreation();
		//this.HomePage();
		//this.PostTest();		
		//this.URLTest();
		//this.ListNPCs();
		//this.TrackVicinity();
		//this.RotateCharacter();
		//this.AbortTest();
		//this.AddMission();
		//this.TestNotification();
		//this.CreateDialog();
		//this.TestWorldStory();
		// this.TestBrowser();
		//this.TestSound();
		//this.DirectX11Test();
		//this.StartNewMission();
		//this.StopMission();
		//this.RemoveWaypoints();
		//m_Instance 680, m_Type 51320
		//AvailableQuests.ID = 2893
		//40:14936, 
		//43:12637
		//this.Translate();
		//this.WearCloth();
		//this.LooksPackage();
		//this.ListEffectsPackage();
		//this.GetClothing();
		//this.SetAnimation();
		//this.EffectsPackage();
		//this.HitDaFlo();
		//this.AddLooksTier("Civilian", 99, 7569838, "Carter");
		////this.AddLooksTier("Civilian", 99, 7164010, "Carter");		
		//this.AddLooksTier("Civilian", 99, 8227413, "Shirt",false,true);
		//this.AddLooksTier("Civilian", 99, 8227414, "Jacket",false,true);
		//this.AddLooksTier("Civilian", 99, 8227416, "Pants",false,true);
		////this.AddLooksTier("Civilian", 99, 8395604, "Panties", false, true);
		//this.AddLooksTier("Civilian", 99, 8229384, "Heels", false, true);
		//this.AddLooksTier("Civilian", 99, 7419046, "Hands", false, true);
		//this.AddLooksTier("Civilian", 99, 7116432, "Hair",false,true);
		//this.AddLooksTier("Civilian", 99, 7987827, "Hat",false,true);
		//this.AddLooksTier("Civilian", 99, 7028883, "Mei Ling");
		//this.LoadLooksXML();
		//this.TestAnimationTier();
		//this.TestTextMerge();
		//this.MonsterTest();
		//this.MosterLoginTest();
		//this.CamTest();
		//this.CharacterCam();
		//this.AddWaypoint();
		//this.MoveWaypoint();
		//this.ScreenPosition();
		//this.DeleteQuest();
		//this.LabelDynels();
		//this.CustodianWaypoint();
		this.TestLooksConfig();
		//this.IsPlayerDead();
		//this.TestTarget();
		//this.TestScale();		
		//this.ShowDValue("GUIResolutionScale");
		//this.SignalQuestAvailable();
		//this.LocationTest();
		
		var tier_4 = this.AddTier("useitem", "There is no spoon.");
		tier_4.SetItem("thereisnospoon");		
		
		var tier5:LooksTier = this.AddTier("looks", "Reset Looks");
		tier5.m_ResetLooks = true;
		//tier5.ResetLooks();			

	}
	
	function LocationTest()
	{
		var tier:LocationTier = this.AddTier("location", "Location Test");
		tier.SetLocation(5060, 400, 375, 265, 3, 3, "Test Waypoint");
	}
	
	function SignalQuestAvailable()
	{
		com.GameInterface.QuestsBase.SignalQuestAvailable.Connect(OnQuestAvailable, this);
	}
	
	function OnQuestAvailable(idQuestGiver:Number, questName:String, mainQuestType:Number, unused:Number, questGiverType:Number, questGiverInstance:Number, tier:Number )
	{
		_root.fifo.SlotShowFIFOMessage("idQuestGiver: " + idQuestGiver + "\n" + "questName: " + questName + "\n" + "mainQuestType: " + mainQuestType + "\n" +
			"questGiverType: " + questGiverType + "\n" + "questGiverInstance: " + questGiverInstance + "\n" + "tier: " + tier)
	}
	
	function ShowDValue(valueName)
	{
		var value = com.GameInterface.DistributedValueBase.GetDValue(valueName);
		_root.fifo.SlotShowFIFOMessage(valueName + ": " + value);
	}
	
	function TestScale()
	{
		var scale = 200;
		_root._xscale = scale;
		_root._yscale = scale;
		
	}
	
	function TestTarget() {
		_root.fifo.SlotShowFIFOMessage("TestTarget()");
		com.Utils.GlobalSignal.SignalCrosshairTargetUpdated.Connect(SlotCrosshairTargetUpdated, this);
	}
	
	function SlotCrosshairTargetUpdated(newTargetID:ID32)
	{
		var name =  Character.GetCharacter(newTargetID).GetName();
		_root.fifo.SlotShowFIFOMessage("SlotCrosshairTargetUpdated: " + name);
		ULog.Error("Target Name: " + name);
	}
	
	function IsPlayerDead() {
		var dead = this.m_Player.m_Character.IsGhosting()
		_root.fifo.SlotShowFIFOMessage("Ghosting: " + dead);
	}
	
	function TestLooksConfig() {
		var tier:LooksTier = this.AddTier("looks", "Test Looks Config");
		tier.SetTarget("player");
		//tier.AddLooks("6940248", "carter");
		tier.AddLooks("7569838", "head_1_new-england_female_carter_gameplay");
		//tier.AddLooks("9138326", "cit_multislot_female_nude", false, "26611");
		//tier.AddLooks("6869379", "CC_headmesh_cau_female_01", false, "4343");
		tier.AddLooks("7355905", "makeup");		
		//tier.AddLooks("7569838", "head_1_new-england_female_carter_gameplay");
		//tier.AddLooks("6869378", "CC_headmesh_cau_male_01", false, "16295");
		//tier.AddLooks("7116432", "CC_hair_female", false, "18625");
		//tier.AddLooks("7116447", "CC_hair_tint", false, "4556");
		//tier.AddLooks("6960816", "CC_facial_hair_female", false, "6684");
		//tier.AddLooks("7116405", "CC_hair_male");
		//tier.AddLooks("7116405", "CC_hair_male", false, "4570");
		tier.AddLooks("7729481", "shirt");
		tier.AddLooks("7419974", "coat");
		tier.AddLooks("8150248", "pants");
		tier.AddLooks("7356216", "shoes");
		tier.AddLooks("7419046", "hands");
		tier.AddLooks("7994021", "earrings");
		return;
		//this.CheckConfigID(tier, "9138326");
		//this.CheckConfigID(tier, "7863510");
		//this.CheckConfigID(tier, "7863511");
		//this.CheckConfigID(tier, "7863512");
		//this.CheckConfigID(tier, "7863541");
		//this.CheckConfigID(tier, "7863542");
		//this.CheckConfigID(tier, "7863543");
		//this.CheckConfigID(tier, "7863544");
		//for (var i = 6869378; i <= 6869385; i++) {
			//this.CheckConfigID(tier, i.toString());
		//}
	}
	
	function CheckConfigID(tier, id) {
		
		// Find valid config IDs
		// Invalid IDs will be logged
		for (var i = 1; i < 30000; i++) {
			tier.AddLooks(id, "CheckConfigID", false, i.toString());
		}
		_root.fifo.SlotShowFIFOMessage("Config ID Complete: " + id);
	}

	function LabelDynels() {
		var nearDynels = _root.interactioncontroller.m_InteractionDynels;
		for (var prop in nearDynels) {
			this.DialogueWindow(nearDynels[prop].GetID(),nearDynels[prop].GetName());
		}
	}
	
	function DialogueWindow(targetID, targetName) {
		//var targetID = m_Player.m_Character.GetDefensiveTarget();
		//var target = Character.GetCharacter(targetID);
		_global.m_MissionDebugWindow.contentTextField.text = "Name:" + targetName + "\n" + _global.m_MissionDebugWindow.contentTextField.text;
		var dc = _root.dialoguecontroller;
		var dlg = dc.CreateDialogueWindow(targetID);
		//dlg.configUI();
		dlg.m_USName = dlg.attachMovie("DynelName", "m_DynelName", dlg.getNextHighestDepth());
		dlg.m_USName.m_Name.textField.text = targetName;
		var questions = ["Question 1", "Question 2", "Question 3"];
		dlg.SetQuestions(questions);
		_global.setTimeout(this, "SetVisible", 100, dlg);
	}
	
	function SetVisible(dlg) {
		dlg._visible = true;
	}
	
	function CustodianWaypoint() {
		DialogueBase.SignalVoiceStarted.Connect(SlotVoiceStarted, this);
		//DialogueBase.JumpToTopic = function (npcID:ID32, topicIndex:Number, topicNum:Number) {
			//_root.fifo.SlotShowFIFOMessage("npcID: " + npcID + ", index: " + topicIndex + ", num: " + topicNum);
		//}
		DialogueBase.JumpToTopic(new ID32(50000, 23), 0, 1);
	}
	
	function SlotVoiceStarted(voiceHandle:Number)
	{
		_root.fifo.SlotShowFIFOMessage("voiceHandle: " + voiceHandle);
	}
	
	function DeleteQuest() {
		// Doesn't do anything
		Quests.DeleteCurrentQuestOfMainQuest( 3176);
	}
	
	function AddWaypoint()
	{
		
		//400, 376, 263
		var x = 400;
		var y = 376;
		var z = 263;
		//var x = 689.76495361328;
		//var y = 49.836078643799;
		//var z = 666.05035400391;
		//var nearDynels = _root.interactioncontroller.m_InteractionDynels;
		//var dynel: Dynel;
		//for (var prop in nearDynels) {
			//dynel = nearDynels[prop];
			//break;
		//}
		// var dynel: Dynel = _root.interactioncontroller.m_InteractionDynels[1];
		var dynel: Dynel = this.m_Player.m_Character;
		_root.fifo.SlotShowFIFOMessage("dynel: " + dynel.GetID() + " " + dynel.GetName());
		var waypoint: Waypoint = new com.GameInterface.Waypoint();
		waypoint.m_Id = new ID32(43,12367);
		waypoint.m_WaypointType = _global.Enums.WaypointType.e_RMWPPvPDestination;
		waypoint.m_Label = "Test Waypoint";
		waypoint.m_IsScreenWaypoint = true;
		waypoint.m_IsStackingWaypoint = true;
		waypoint.m_Radius = 0;
		waypoint.m_Color = 255;
		//waypoint.m_WaypointState = 0;
		waypoint.m_WaypointState = _global.Enums.QuestWaypointState.e_WPStateActive;
		//waypoint.m_ScreenPositionX = 942; // -90000;
		//waypoint.m_ScreenPositionY = 600;	//0;
		var pos: flash.geom.Point = dynel.GetScreenPosition();
		_root.fifo.SlotShowFIFOMessage("pos.x: " + pos.x);
		_root.fifo.SlotShowFIFOMessage("pos.y: " + pos.y);
		waypoint.m_ScreenPositionX = pos.x - 130; // 0; // -90000;
		waypoint.m_ScreenPositionY = pos.y + 100; // 0;	//0;
		waypoint.m_CollisionOffsetX = 0;
		waypoint.m_CollisionOffsetY = 0;
		waypoint.m_WorldPosition = new com.GameInterface.MathLib.Vector3(x,y,z);
		waypoint.m_MinViewDistance = 0;
		waypoint.m_MaxViewDistance = 0;
		waypoint.m_DistanceToCam = 0;

		//_root.waypoints.m_CurrentPFInterface.m_Waypoints[waypoint.m_Id.toString()] = waypoint;
		_root.waypoints.m_CurrentPFInterface.m_Waypoints["43:12367"] = waypoint;
		_root.waypoints.m_CurrentPFInterface.SignalWaypointAdded.Emit(waypoint.m_Id);
		_root.waypoints.UpdateScreenWaypoints();
		UpdateWaypoint(waypoint);
	}
	
	function UpdateWaypoint(waypoint:Waypoint)
	{
		// Didn't work. Don't have enough info about camera angles to find screen position
		if (waypoint) {
			_global.m_MissionDebugWindow.contentTextField.text = "";
			var cam:Vector3 = Camera.m_Pos;
			if (Camera.GetZoom() != m_LastZoom) {
				m_LastZoom = Camera.GetZoom();
				//_global.m_MissionDebugWindow.contentTextField.text += "Zoom: " + m_LastZoom + "\n";
			}
			var pos:Vector3 = waypoint.m_WorldPosition;
			// Taken from http://www.calculatorsoup.com/calculators/geometry-solids/distance-two-points.php
			var distance = Math.sqrt(Math.pow(pos.x - cam.x, 2) + Math.pow(pos.y - cam.y, 2) + Math.pow(pos.z - cam.z, 2));
			distance = Math.abs(Math.round(distance));
			waypoint.m_DistanceToCam = distance;
			
			//// Adapted from http://stackoverflow.com/questions/724219/how-to-convert-a-3d-point-into-2d-perspective-projection
			//var width = 1920;
			//var height = 1200;
			//var halfWidth = width * 0.5;
			//var halfHeight = height * 0.5;
			//var fov = 60 * (Math.PI / 180);
			//var aspect = width / height;
			//var near = 0.1;
			//var far = 2000;
			//var w = 1;			
			//// Setup calculation Matrix
			//var m = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];			
			//var f = 1.0 / Math.tan(fov * 0.5);
			//m[0] = f * aspect;
			//m[5] = f;
			//m[10] = (far+near) / (far-near);
			//m[11] = 1.0; /* this 'plugs' the old z into w */
			//m[14] = (2.0*near*far) / (near-far);
			//m[15] = 0.0;
			//
			//var v = Vector3.Sub(cam, pos);
			//v.w = w;
			//var dst = new Object();
			//dst.x = v.x*m[0] + v.y*m[4] + v.z*m[8 ] + v.w*m[12];
			//dst.y = v.x*m[1] + v.y*m[5] + v.z*m[9 ] + v.w*m[13];
			//dst.z = v.x*m[2] + v.y*m[6] + v.z*m[10] + v.w*m[14];
			//dst.w = v.x * m[3] + v.y * m[7] + v.z * m[11] + v.w * m[15];
			
			var compass = Camera.m_AngleY;
			var degrees:Number = ((Math.round(( compass * 180)  / Math.PI) + 360) % 360);
			
			var MyPos: Vector3 = this.m_Player.m_Character.GetPosition( _global.Enums.AttractorPlace.e_Ground );
			//_global.m_MissionDebugWindow.contentTextField.text = "MyPos.x: " + MyPos.x + "\n";
			//_global.m_MissionDebugWindow.contentTextField.text += "MyPos.z: " + MyPos.z + "\n";
			var deltaz = waypoint.m_WorldPosition.z - MyPos.z;
			var deltax = waypoint.m_WorldPosition.x - MyPos.x;
			//_global.m_MissionDebugWindow.contentTextField.text += "deltaz: " + deltaz + "\n";
			//_global.m_MissionDebugWindow.contentTextField.text += "deltax: " + deltax + "\n";
			var hAngle = (Math.atan2(deltax, deltaz));			
			_global.m_MissionDebugWindow.contentTextField.text += "hAngle: " + hAngle + "\n";;
			//_global.m_MissionDebugWindow.contentTextField.text += "Compass: " + compass + "\n";
			var waypointAngle = compass + hAngle;
			_global.m_MissionDebugWindow.contentTextField.text += "wpAngle: " + waypointAngle  + "\n";
			
			//var screenx = (dst.x * width) / (2.0 * dst.w) + halfWidth;
			//var screeny = (dst.y * height) / (2.0 * dst.w) + halfWidth;			
			
			
			var visibleRect = Stage["visibleRect"];
			// +/- .82 is viewable angle on 16:9 monitor
			//var multiplier = (.82 + waypointAngle) + (1 - .82)
			var multiplier = waypointAngle + 1
			//_global.m_MissionDebugWindow.contentTextField.text += "multiplier: " + multiplier  + "\n";
			var screenx = (visibleRect.width / 2) * multiplier;
			_global.m_MissionDebugWindow.contentTextField.text += "screenx: " + screenx  + "\n";
			waypoint.m_ScreenPositionX = screenx;
			
			var deltay = waypoint.m_WorldPosition.y - MyPos.y;
			var vAngle = Math.abs((Math.atan2(deltaz, deltay)));
			_global.m_MissionDebugWindow.contentTextField.text += "deltay: " + deltay + "\n";
			_global.m_MissionDebugWindow.contentTextField.text += "vAngle: " + vAngle + "\n";
			var vmultiplier = ((vAngle + 1)/Math.PI);
			_global.m_MissionDebugWindow.contentTextField.text += "vmultiplier: " + vmultiplier  + "\n";
			var screeny = Math.max(Math.min((visibleRect.height / 2) * vmultiplier, visibleRect.height * .9), 0);
			_global.m_MissionDebugWindow.contentTextField.text += "screeny: " + screeny  + "\n";
			waypoint.m_ScreenPositionY = screeny;			
			
			waypoint.m_Label = deltay;
			
			_root.waypoints.UpdateScreenWaypoints();
			
			_global.setTimeout(this, "UpdateWaypoint", 100, waypoint);		
			
		}		
	}	
	
	function CharacterCam() {
		//var clip:ClipNode = GUIFramework.SFClipLoader.LoadClip("CharacterCreation.swf", "ccTest" , true, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop, 0, [true]);
		//clip.SignalLoaded.Connect( CCLoaded, this );
		var m_CameraController = new CameraController( CameraController.e_ModeBody );
		m_CameraController.UpdateTargetPositions( this.m_Player.m_Character );
		m_CameraController.FrameProcess();
	}
	
	function CCLoaded() {
		 //GUIFramework.SFClipLoader.SignalFrameStarted.Disconnect( CCLoaded, this );
		//this.MessageBox("State: " + _root.ccTest.m_CurrentMode);
		_root.ccTest.SetState(1);
	}
	
	function MosterLoginTest() {
		m_CharacterCreationIF = new CharacterCreation(false);
		var character:Character = m_CharacterCreationIF.GetCharacter();
		m_CharacterCreationIF.ExitCharacterCreation();
		m_CharacterCreationIF.SetHairStyleIndex(4);
		m_CharacterCreationIF.SetGender(2);
		m_CharacterCreationIF.SetMonsterData(5352715);			
	}
	
	function MonsterTest() {
		//_root.fifo.SlotShowFIFOMessage("MonsterTest");
		com.GameInterface.Game.Camera.PlaceCamera(509 + (m_CamAdjust/100), 413.5, 417 + (m_CamAdjust/100), 511, 413.5, 419.7, 0, 1, 0);
		if (m_CamAdjust == 0) {
			com.GameInterface.DistributedValueBase.SetDValue("CharacterCreationActive", true);	
			m_CharacterCreationIF = new CharacterCreation(true);
			var character:Character = m_CharacterCreationIF.GetCharacter();
			m_CharacterCreationIF.SetHairStyleIndex(4);
			m_CharacterCreationIF.SetGender(2);
			m_CharacterCreationIF.SetMonsterData(5352715);			
		}
		if (m_CamAdjust == 5) {
			m_CharacterCreationIF.SetHairStyleIndex(2);
		}
		m_CamAdjust = m_CamAdjust + .1;
		if (m_CamAdjust < 10){
			//setTimeout(CamTest, 1); 
			_global.setTimeout(this, "MonsterTest", 10);
		}
		else {
	//		com.GameInterface.Game.Camera.SignalCinematicActivated.Emit();
	//		var charcreate = new com.GameInterface.CharacterCreation.CharacterCreation(false);
	//		charcreate.ExitCharacterCreation();
	//		var m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation( m_IsSurgery);
	//		m_CharacterCreationIF.ResetSurgeryData();
	//        UnloadClip();
	
	//		GUIFramework.SFClipLoaderBase.ClipUnloaded("");
			//var m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
			m_CharacterCreationIF = null;
			// m_CharacterCreationIF.ExitCharacterCreation();
			this.MessageBox("Camera complete.");
			com.GameInterface.DistributedValueBase.SetDValue("CharacterCreationActive", false);	
		}	
		
		//Camera.PlaceCamera(811, 78, 188, 814, 78, 184, 0, 1, 0);
		//DistributedValue.SetDValue("CharacterCreationActive", false);	
		//DistributedValue.SetDValue("CharacterCreationActive", true);	
		//m_CharacterCreationIF = new CharacterCreation(true);
		//m_CharacterCreationIF.SetMonsterData(3070173);
		//m_CharacterCreationIF.GetHairStyleIndexes();
		//m_CharacterCreationIF.SetHairStyleIndex(1);
		//m_CharacterCreationIF.SetRandomFacialPreset();
		//m_CharacterCreationIF.SetEyeColorIndex(1);
		//m_CharacterCreationIF.SetEyeColorIndex(0);
	
		//DistributedValue.SetDValue("CharacterCreationActive", false);	
	}
	
	
	function TestTextMerge()
	{
		var tier:BrowserTier = this.AddTier("browser", "Test Text Merge");
		tier.SetURL("data:,TestTextMerge?id={{player.m_CharacterID}}&name={{player.m_Name}}&version={{untold.m_VerNo}}");
		
		var template = "Version: {{untold.m_VerNo}}\n" + 
						"Player: {{player.m_Name}}\n" +
						"Character ID: {{player.m_CharacterID}}\n" +
						"Faction: {{m_Player.m_Faction}}\n" +
						"Gender: {{player.m_Gender}}\n" +
						"Mission Title: {{mission.m_MissionTitle}}\n" +
						"Tier Description: {{tier.m_TierDescription}}\n";						
		var result = USUtils.TextMerge(template);
		_root.fifo.SlotShowFIFOMessage("TestTextMerge\n" + result);
	}
	
	function TestAnimationTier()
	{
		var tier:AnimationTier = this.AddTier("animation", "Animation")
		tier.SetTarget("Moon Kwon,Jin Jae-Hoon",2);
		tier.AddAnimation("cinematic_stationmaster_m_story_01");
		var tier2:LooksTier = this.AddTier("looks", "Looks")
		tier2.SetTarget("Moon Kwon,Jin Jae-Hoon",2);
		tier2.AddLooks("7054745", "StationMaster");
	}
	
	function SetAnimation()
	{
		var anim = "cinematic_stationmaster_m_story_01";
		_root.fifo.SlotShowFIFOMessage("SetAnimation(): " + anim);
		//var targetID = m_Player.m_Character.GetDefensiveTarget();
		//var target = Character.GetCharacter(targetID);
		var target = this.GetNPC('Moon Kwon');
		//var selector:Selector = new Selector();
		//var target = selector.SelectNPC("Singer");
		//target.SetBaseAnim("normal_emote_idlepose_leanonwall_back");
		target.SetBaseAnim(anim);
		return;
		m_Dynel = target;
		_global.setTimeout(this, "LipSync", 5000);
		_global.setTimeout(this, "LipSync", 10000);
		_global.setTimeout(this, "LipSync", 15000);
		_global.setTimeout(this, "LipSync", 20000);
		
		var target2 = this.GetNPC("Doctor Bannerman");
		target2.SetBaseAnim("cinematic_hana_m_story_01_player");
		var target3 = this.GetNPC("Hayden Montag");
		target3.SetBaseAnim("cinematic_annabel_m_story_hayden");
	
	}	
	
	function LoadLooksXML()
	{
		var description = "npc_new-england_female_carter";
		ULog.Info("Loading LooksRDB.xml");
		var xml:XML = new XML();
		xml.ignoreWhite = true;
		xml.onLoad = function( isLoaded:Boolean )
		{
		  if (isLoaded) {
			_root.fifo.SlotShowFIFOMessage("LooksRDB.xml Loading Complete: " + xml.firstChild.nodeName);
			ULog.Info("LooksRDB.xml Loaded");
			var query = "VFPData/looksrdb[@desc='" + description + "']";
			//var query = "looksrdb";
			_root.fifo.SlotShowFIFOMessage("query: " + query);
			var xmlNode:XMLNode = XPathAPI.selectSingleNode(xml.firstChild, query);
			_root.fifo.SlotShowFIFOMessage("xmlNode.length: " + xmlNode.attributes.rdbid);
			ULog.Info("Looks xmlNode: " + xmlNode);
		  } else {
			ULog.Info("LooksRDB.xml Loading Error");
			_root.fifo.SlotShowFIFOMessage("LooksRDB.xml Loading Error");
		  }
		}
		_root.fifo.SlotShowFIFOMessage("LooksRDB.xml Loading...");
		xml.load( "Untold/LooksRDB2.xml" );
	}
	
	function AddLooksTier(npcNames, qty, looksPackageRDBID, description, reset, keepLooks)
	{
		if (m_LastTier) {
			m_LastTier.m_TierDescription = m_LastTier.m_TierDescription + "\nNext: " + description;
		}
		var looksTier = this.AddTier("looks", description);
		looksTier.SetLooks(npcNames, qty, looksPackageRDBID, description, reset, keepLooks);
		m_LastTier = looksTier;
	}
	
		function LipSync()
	{
		_root.fifo.SlotShowFIFOMessage("LipSync()");
		// What
		//_global.setTimeout(this, "Anim", 10 , m_Dynel, "lipsynch_w");
		_global.setTimeout(this, "Anim", 100, m_Dynel, "lipsynch_m_b_p_x");
		_global.setTimeout(this, "Anim", 500, m_Dynel, "lipsynch_aa_ao_ow");
		//_global.setTimeout(this, "Anim", 200, m_Dynel, "lipsynch_n-ng-ch-j-dh-d-g-t-k-z-zh-th-s-sh");
		_global.setTimeout(this, "Anim", 900, m_Dynel, "lipsynch_m_b_p_x");
		//_global.setTimeout(this, "Anim", 900, m_Dynel, "lip_neutral");
		return;
		
		_global.setTimeout(this, "Anim", 0, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 10, m_Dynel, "lipsynch_aa_ao_ow");
		_global.setTimeout(this, "Anim", 100, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 200, m_Dynel, "lipsynch_aw");
		_global.setTimeout(this, "Anim", 300, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 400, m_Dynel, "lipsynch_f_v");
		_global.setTimeout(this, "Anim", 500, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 800, m_Dynel, "lipsynch_ih-ae-ah-ey-h");
		_global.setTimeout(this, "Anim", 900, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 1000, m_Dynel, "lipsynch_iy_eh_y");
		_global.setTimeout(this, "Anim", 1100, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 1200, m_Dynel, "lipsynch_l_el");
		_global.setTimeout(this, "Anim", 1300, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 1400, m_Dynel, "lipsynch_m_b_p_x");
		_global.setTimeout(this, "Anim", 1500, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 1600, m_Dynel, "lipsynch_n-ng-ch-j-dh-d-g-t-k-z-zh-th-s-sh");
		_global.setTimeout(this, "Anim", 1700, m_Dynel, "lip_neutral");
		_global.setTimeout(this, "Anim", 1800, m_Dynel, "lipsynch_r_er");
		_global.setTimeout(this, "Anim", 2000, m_Dynel, "lip_neutral");
	}
	
	function Anim(target, animation)
	{
		//_root.fifo.SlotShowFIFOMessage("Anim(): " + animation);
		target.SetBaseAnim(animation);
	}
	
	function GetNPC(name)
	{
		var npc = undefined;
		var nearDynels = _root.interactioncontroller.m_InteractionDynels;
		for (var prop in nearDynels) {
			if (nearDynels[prop].GetName().toLowerCase() == name.toLowerCase()) {
				npc =  Character.GetCharacter(nearDynels[prop].GetID());
				break;
			}
		}
		_root.fifo.SlotShowFIFOMessage("NPC: " + npc.GetName());
		return npc;
	}

	function EffectsPackage()
	{
		var effect = "fx_weapon_shotgun_impact_04.xml";
		_root.fifo.SlotShowFIFOMessage("EffectsPackage(): " + effect);
		//var targetID = m_Player.m_Character.GetDefensiveTarget();
		//var target = Character.GetCharacter(targetID);
		var target = m_Player.m_Character;
		target.AddEffectPackage(effect);
	}
	
	function MoveWaypoint()
	{
		//var waypoint = _root.waypoints.m_CurrentPFInterface.m_Waypoints["43:18120"];
		// Get first waypoint
		var waypoint;
		for(var id:String in _root.waypoints.m_CurrentPFInterface.m_Waypoints) {
			waypoint = _root.waypoints.m_CurrentPFInterface.m_Waypoints[id];
			break;
		}
		waypoint.m_WorldPosition.x = 272;
		waypoint.m_WorldPosition.y = 161.25;
		waypoint.m_WorldPosition.z = 384;
		waypoint.m_Label = "Test Waypoint";
		waypoint.m_IsScreenWaypoint = true;
		waypoint.m_IsStackingWaypoint = true;
		waypoint.m_Radius = 0;
		waypoint.m_Color = 255;
		waypoint.m_WaypointState = 0;
		waypoint.m_WaypointType = _global.Enums.WaypointType.e_RMWPPvPDestination;
		//waypoint.m_Id.m_Instance = 99999;
		//_root.waypoints.m_CurrentPFInterface.SignalWaypointMoved(waypoint.m_Id);
		//_root.waypoints.m_CurrentPFInterface.GetExistingWaypoints(_root.waypoints.m_PlayfieldID);
		//_root.waypoints.UpdateScreenWaypoints();
		_root.waypoints.m_CurrentPFInterface.SignalWaypointAdded.Emit(waypoint.m_Id);

	}


	function HitDaFlo()
	{
		//this.AddLooksTier(undefined, "Reset", true);
		
		//this.AddLooksTier(7395107, "Callisto");
		//this.AddLooksTier(6697044, "Richard Sonnac");
		//this.AddLooksTier(7752815, "Invisible");
		this.AddLooksTier(6941682, "Mr. Rosenbaum");
		this.AddLooksTier(6988847, "Miss Plimmswood");
		this.AddLooksTier(8941482, "Nephilim");
		this.AddLooksTier(8157841, "Mankini", false, true);
		this.AddLooksTier(7646024, "Lilith");
		this.AddLooksTier(8428728, "Samael");
		this.AddLooksTier(6974182, "Doctor Bannerman");
		this.AddLooksTier(6940268, "Madame Roget");
		this.AddLooksTier(7029113, "Zuberi");
		this.AddLooksTier(7028889, "Rose White");
		this.AddLooksTier(7029105, "Alex McCall");
		this.AddLooksTier(7028883, "Mei Ling");
		this.AddLooksTier(6699649, "Danny Dufresne");
		this.AddLooksTier(6940248, "Carter");
		this.AddLooksTier(6862257, "Emilia");
		this.AddLooksTier(6862258, "Vlad Dracula");
		this.AddLooksTier(8320698, "Mara (Good)");
		this.AddLooksTier(6940253, "Cassandra King ");
		this.AddLooksTier(7118672, "Said");
		//this.AddLooksTier(rdbid, "Name");
		//this.AddLooksTier(rdbid, "Name");
		//this.AddLooksTier(rdbid, "Name");
		
	}
	

	function GetClothing()
	{
		//var characterID = m_Player.m_CharacterID;
		var characterID = m_Player.m_Character.GetDefensiveTarget();
		var m_ClothesInspectionInventory = new com.GameInterface.Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, characterID.GetInstance()));
		m_ClothingItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest);
		_root.fifo.SlotShowFIFOMessage("Clothing Item: " + m_ClothingItem.m_Name);
	}
	
	function LooksPackage() 
	{

		var targetID = m_Player.m_Character.GetDefensiveTarget();
		var target = Character.GetCharacter(targetID);
/*		
		_root.fifo.SlotShowFIFOMessage("Starting loop...");
		for (var i = 0; i < 250000; i++) {
			var pkg = 8750000 + (i * 1);
			target.AddLooksPackage(pkg);
		}
		_root.fifo.SlotShowFIFOMessage("Loop complete.");
		return;
		
		var looksTier1 = this.AddTier("looks", "Miss Plimmswood");
		//looksTier1.SetLooks(6940248, "Carter");
		looksTier1.SetLooks(6988847, "Miss Plimmswood");		
	
		var looksTier1a = this.AddTier("looks", "Mr Rosenbaum");
		looksTier1a.SetLooks(6941682, "Mr Rosenbaum");		

		var looksTier2 = this.AddTier("looks", "Reset");
		looksTier2.SetLooks(undefined, undefined, true);
		return;
*/
		
//		target.RemoveLooksPackage(6966889);
		//target.RemoveLooksPackage(6941926);
//		target.AddEffectPackage(396353);
		//target.RemoveLooksPackage(6940248);
		//target.Reinitialize();
		//var shop = new com.GameInterface.ShopInterface();
		//shop.PreviewItem(0);
		target.RemoveAllLooksPackages();
		//DistributedValue.SetDValue("CharacterCreationActive", true);	
		//m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
		//m_CharacterCreationIF.GetHairStyleIndexes();
		//m_CharacterCreationIF.SetHairStyleIndex(1);
		//m_CharacterCreationIF.SetRandomFacialPreset();
		//m_CharacterCreationIF.SetEyeColorIndex(1);
		//m_CharacterCreationIF.SetEyeColorIndex(0);
	
		//DistributedValue.SetDValue("CharacterCreationActive", false);	
	
		//m_CharacterCreationIF.WearCloth( 2, 0 );
		//m_CharacterCreationIF.ResetSurgeryData();		
		//m_CharacterCreationIF = null;


		target.AddLooksPackage(7752815); // invisible
		//target.AddLooksPackage(8974569);
		//target.AddLooksPackage(8974945);
		//target.AddLooksPackage(7561515);
		//target.AddLooksPackage(7656582);
		    
		//target.AddLooksPackage(7656582);
		//target.AddLooksPackage(6862249);
		//target.AddLooksPackage(7569923);
		//target.AddLooksPackage(8907654);
		target.AddLooksPackage(7115951);
		
		
		return;
		
		var resetTier = this.AddTier("looks", "Reset");
		resetTier.SetLooks(undefined, undefined, true);
		
		var rdbXML = new XML();
		rdbXML.ignoreWhite = true;
		rdbXML.load('Untold/lookspkg.xml');
		var thisList = this;
		rdbXML.onLoad = function(success) {
			if (success) {
				_root.fifo.SlotShowFIFOMessage("Success loading lookspkg.xml");
				var rdbListNode:XMLNode = rdbXML.firstChild;
				_root.fifo.SlotShowFIFOMessage(rdbListNode.nodeName);
				_root.fifo.SlotShowFIFOMessage("Records: " + rdbListNode.childNodes.length.toString());
				var newpkg = 0;
				var oldpkg = 0;
				var tier;
				var desc;
				for (var i = 0; i < rdbListNode.childNodes.length; i++) {
					var rdbNode:XMLNode = rdbListNode.childNodes[i];
					if (rdbNode) {
						newpkg = int(rdbNode.attributes.rdbid);
						if (newpkg >= 1000000) {
							desc = rdbNode.attributes.desc
							//_global.setTimeout(thisList, "AddPackage", i * 1000, target, newpkg, oldpkg);
							tier = thisList.AddTier("looks", "RDBID: " + newpkg + "\n" + desc);
							tier.SetLooks(newpkg, desc);
							oldpkg = newpkg;
						}
					}
				}
			} 
			else {
				_root.fifo.SlotShowFIFOMessage("Error loading lookspkg.xml");
			}
		};
		return;


		for (var i = 0; i < 2; i++) {
			var pkg = 6940308 + (i * 1);
			_global.setTimeout(this, "AddPackage", i * 2000, target, pkg, pkg-1);
		}
		return;
		
		// this.ListLooksPackage();
		// 7000000 - 7500000: Hair
		// 7500000 - 8000000: Clothes 
		// 7500000 - 7600000: Top
		// 7600000 - 7700000: ?
		// 7700000 - 7800000: ?
		// 7800000 - 7900000: ?
		// 7900000 - 8000000: Pants, shoes, necklace
		// 7553967 IO8T Top
		// 6966889 Illuminati Uniform female
		// this.ListEffectsPackage();
		for (var i=0; i<10; i++) {
			var start = 6940260 + (i * 1);
			var end = 6940260 + ((i + 1) * 1);
			_global.setTimeout(this, "RemovePackages", i * 1500, target, start, end);
		}
		
		//this.RemovePackages(target, 6000000, 7000000);
/*		for (var i=0; i<100; i++) {
			_global.setTimeout(this, "AddPackage", i * 1500, i + 7553990, i + 7553900 - 1);
		}
*/		
//		for (var i=7500000;i<7600000;i++) {
//			m_Player.m_Character.AddLooksPackage(i);
//		}
//		m_Player.m_Character.RemoveAllLooksPackages();
//		for (var i=10000000;i<20000000;i++) {
//			m_Player.m_Character.RemoveEffectPackage(i);
//		}
	}
	
	function AddPackage(character, newPackage, oldPackage)
	{
		_root.fifo.SlotShowFIFOMessage("AddPackage:" + newPackage.toString());
		character.RemoveAllLooksPackages();
		//character.RemoveLooksPackage(oldPackage);
		character.AddLooksPackage(newPackage);
	}


	function RemovePackages(character, start, end)
	{
		_root.fifo.SlotShowFIFOMessage("Remove:" + start.toString() + " - " + end.toString());
		for (var i=start;i<end;i++) {
			character.RemoveLooksPackage(i);
		}
	}
	
	function ListEffectsPackage()
	{
		m_Player.m_Character.AddLooksPackage = function(packageName:String) {
			_root.fifo.SlotShowFIFOMessage("Package:" + packageName.toString(), 0);
		}
	}

	function ListLooksPackage() 
	{
		_global.m_MissionDebugWindow.contentTextField.text = "ListLooksPackage\n";
		m_Player.m_Character.AddLooksPackage = function(looksPackageRDBID:Number, looksConfiguration:Number) {
			_global.m_MissionDebugWindow.contentTextField.text = "RDB: " + looksPackageRDBID.toString() 
				+ "\nConfig: " + looksConfiguration.toString() + _global.m_MissionDebugWindow.contentTextField.text
		}
	}

	function Translate()
	{
		_root.fifo.SlotShowFIFOMessage(LDBFormat.LDBGetText(51000, 14271));
		_root.fifo.SlotShowFIFOMessage(LDBFormat.Translate("The Stationmaster"));
		_root.fifo.SlotShowFIFOMessage(LDBFormat.GetCurrentLanguageCode());
	}
	
	function RemoveWaypoints()
	{
		_root.waypoints.m_CurrentPFInterface.m_Waypoints = undefined;
	}
	
	function StartNewMission()
	{
		if (_root.missiontracker.m_MissionBar["Slot6"].m_MissionTrackerItem == undefined) {
			_root.fifo.SlotShowFIFOMessage("Starting mission...");
			com.GameInterface.Quests.AcceptQuestFromQuestgiver(2908, new ID32(0, 0)) // Mission persons
		} else {
			_root.fifo.SlotShowFIFOMessage("No mission slot available.");
		}
		//com.GameInterface.Quests.AcceptQuestFromQuestgiver( 2893, new ID32(51320, 680)) // Mission persons
		//com.GameInterface.Quests.AcceptQuestFromQuestgiver( 2918, new ID32(51320, 783)) // Trespassers
		//com.GameInterface.Quests.AcceptQuestFromQuestgiver( 3176, new ID32(51320, 783)) // Bullets for Andy
		// 3176
		// 1325:51320
		// 4024 - Museum
		// 51320,29691 2908
	}
	
	function StopMission()
	{
		//com.GameInterface.Quests.SignalMissionCompleted.Emit(2893);
		com.GameInterface.Quests.SignalMissionFailed.Emit(2918);
	}
	
	function DirectX11Test()
	{
		// Disconnect damage tracking
	    com.Utils.GlobalSignal.SignalDamageNumberInfo.Disconnect( _root.damageinfo.SlotDamageInfo);
	    com.Utils.GlobalSignal.SignalDamageTextInfo.Disconnect( _root.damageinfo.SlotShowText);
		
	}
	
	function TestSound()
	{
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_select_faction_Templar.xml");
		//m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_select_faction_Dragon.xml");
		m_Player.m_Character.AddEffectPackage("sound_fxpackage_GUI_select_faction_Illuminati.xml");
	}
	
	function TestBrowser()
	{
		//var browser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Facebook);
		//var browser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Browser);

		var browser = _root["untold\\untold"].GetBackgroundBrowser();
/*
		for (var i=-1; i<8; i++) {
			var browser = new Browser(i);
			browser.OpenURL("http://ingame.thesecretworld.com/");
		}
		
*/	}
	
	function TestWorldStory()
	{
		m_WorldStory = new WorldStoryBrowser();
		m_WorldStory.m_StoryID = "Google";
		m_WorldStory.m_Type = "Story";
		m_WorldStory.m_StoryTitle = "Ladies and Gentlemen... Google";
		m_WorldStory.m_SubTitle = "by Super Jenius";
		//m_WorldStory.m_Teaser = "Ladies and Gentlemen... Google";
		m_WorldStory.SetLocation(3030, 192, 153, 328, 5, 1);
		m_WorldStory.SetURL("http://www.google.com");
		m_WorldStory.StartTracking();

		var m_WorldStory2 = new WorldStoryBrowser();
		m_WorldStory2.m_StoryID = "Steeplechase";
		m_WorldStory2.m_Type = "Story";
		m_WorldStory2.m_StoryTitle = "Kingsmouth Track & Field: Steeplechase";
		m_WorldStory2.m_SubTitle = "by Aerinn";
		//m_WorldStory2.m_Teaser = "On the other hand... Yahoo!";
		m_WorldStory2.SetLocation(3030, 213, 147, 324, 5, 1);
		m_WorldStory2.SetURL("https://docs.google.com/document/d/1z6GSMOWmr1qU7r9gPP2DhXMFIPe5EracOb4NHJt_ALk/edit?pli=1");
		m_WorldStory2.StartTracking();
	}
	

	function CreateDialog()
	{
		var id = new ID32(50000);
		var dynel = new Dynel(id);
		var dialog = _root.dialoguecontroller.CreateDialogueWindow(id);
		if (dialog) {
			var quest:com.GameInterface.Quest = new com.GameInterface.Quest();
			quest.m_ID = 2318;	// 99999
			quest.m_MissionName = "Test Quest";
			quest.m_MissionDesc = "This is a test quest.  This shows up in the quest description.";
			quest.m_MissionType = _global.Enums.MainQuestType.e_Story;

			dialog.m_QuestGiver.m_AvailableQuests.push(quest);
			dialog.Clear();
			dialog.DrawMissions();
			if (dynel.HasDialogue())
			{
				dialog.DrawDialogue();
			}
			//dialog.CheckHide();
		}
		
	}
	
	function TestNotification()
	{
		// Constants
		var AP_VALUE:Number = 1;
		var SP_VALUE:Number = 2;
		var AUXILIARY_VALUE:Number = 5437;
		var AUGMENT_UNLOCK_VALUE:Number = 6277;
		var AUGMENT_DAMAGE_VALUE:Number = 3101;
		var AUGMENT_SUPPORT_VALUE:Number = 3201;
		var AUGMENT_HEALING_VALUE:Number = 3301;
		var AUGMENT_SURVIVABILITY_VALUE:Number = 3401;
		var AEGIS_UNLOCK_VALUE = 6817;
		var AEGIS_SHIELD_VALUE = 6818;
		
		var TDB_AUXILIARY_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AuxiliaryWeaponSlotActivated");
		var TDB_AUGMENT_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AugmentSlotsActivated");
		var TDB_AEGIS_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AegisSlotsActivated");
		var TDB_AEGIS_SHIELD_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AegisShieldActivated");
		var TDB_AUGMENT_LEARNED: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AugmentLearned");
		var TDB_EFFECT_TEXTS:Array = [
									  LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_Aegis1"),
									  LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AchievementFailed")
									 ]


		//_root.geteffectscontroller.GetNotificationEffect(AEGIS_UNLOCK_VALUE);
		//_root.geteffectscontroller.SlotMissionComplete();
		//_root.geteffectscontroller.SlotTagAdded(AUXILIARY_VALUE, m_Player.m_Character.GetID());
		//_root.geteffectscontroller.GetSMS(7080599);
		//_root.geteffectscontroller.GetSMS(5777473);
		//_root.geteffectscontroller.GetSMS(6378209);
		//_root.geteffectscontroller.GetSMS(6378211);
		//_root.geteffectscontroller.GetSMS(6391450);

        var dc = _root.dialoguecontroller;
		var link = _root.animawheellink;
		var time;
		var pres = 0;

		for (var i=0; i<2; i++) {		
			m_UWIcon = link.attachMovie("BrokenItemsIcon", "m_UWIcon" + i.toString(), link.getNextHighestDepth());
			link.SetVisible(m_UWIcon, false);
			//m_UWIcon.attachMovie("LoreIcon", "m_UWIcon2", m_UWIcon.getNextHighestDepth());
			//m_UWIcon.m_UWIcon2._alpha = 50;
			//var icon2 = m_UWIcon.attachMovie("AnimaPointsIcon", "m_UWIcon2", m_UWIcon.getDepth()-1);
			//icon2.m_NotificationText.text = ""; 
			//icon2._alpha = 120;
			m_UWIcon.createTextField("m_NotificationText", m_UWIcon.getNextHighestDepth(), 0, 1, 35, 33.10);
			
			//m_UWIcon.m_NotificationText.textHeight = 29.10000038147; 
			//m_UWIcon.m_NotificationText.textWidth = 27.700000762939; 
			//m_UWIcon.m_NotificationText.embedFonts = true;

			//m_UWIcon.m_NotificationText.textColor = 16777215; 
			m_UWIcon.m_NotificationText.text = "US"; 
			var fmt:TextFormat = new TextFormat();
			fmt.align = "center";
			fmt.bold = true;
			fmt.color = 16777215;
			fmt.font = "Futura Heavy Fix";
			fmt.size = 23;
			fmt.leading = 2;
			m_UWIcon.m_NotificationText.setTextFormat(fmt);
			m_UWIcon.fmt = m_UWIcon.m_NotificationText.getTextFormat();
			link.CreateRealTooltip(m_UWIcon, "Untold Stories\nof The Secret World", "Story #" + i.toString());
			
	//		m_UWIcon.onPress = function() {
	//			_root.fifo.SlotShowFIFOMessage("Icon Clicked");
	//		}

			m_UWIcon.onPress = function(){
				//_root.fifo.SlotShowFIFOMessage("Click");
				pres++;
				if(pres == 1){
					time = setInterval(function() {
						pres = 0;
						clearInterval(time);
						_root.fifo.SlotShowFIFOMessage("Single click");
				   }, 400);
				} else {
					pres = 0;
					clearInterval(time);
					_root.fifo.SlotShowFIFOMessage("Double click");
					link.SetVisible(this, false);
					this.removeMovieClip();
				}
			}

			function timeOut(dblClick:Boolean){
				pres = 0;
				clearInterval(time);
				if (dblClick == true) {
					_root.fifo.SlotShowFIFOMessage("Double click");
				}
				else {
					_root.fifo.SlotShowFIFOMessage("Single click");
				}
			}
			//var dropShadow:DropShadowFilter = new DropShadowFilter(4, 45, 0x000000, 0.4, 10, 10, 2, 3);
			//var dropShadow:DropShadowFilter = new DropShadowFilter();
			//m_UWIcon.m_NotificationText.filters = [dropShadow];

			link.SetVisible(m_UWIcon, true);
		}
		//m_UWIcon.m_NotificationText.swapDepths(m_UWIcon.m_UWIcon2);
		//m_UWIcon.m_UWIcon2.m_NotificationText._alpha = 200;
		link.SetVisible(link.m_AnimaPointsIcon, true);
    	link.SetVisible(link.m_SkillPointsIcon, true);
		link.SetVisible(link.m_LoreIcon, true);
		//link.SetVisible(link.m_SMSIcon, true);
//		link.SetVisible(link.m_LoreFilthIcon, true);
//		link.SetVisible(link.m_AchievementIcon, true);
//		link.SetVisible(link.m_BrokenItemsIcon, true);
//		link.SetVisible(link.m_BreakingItemsIcon, true);
//		GUI.Mission.MissionSignals.SignalSMSAnimationDone.Emit(7080599);
//		GUI.Mission.MissionSignals.SignalSMSAnimationDone.Emit(5777473);


	}
	
	function AddMission()
	{
		var targetID = m_Player.m_Character.GetDefensiveTarget();
		var target = Character.GetCharacter(targetID);
		_root.dialoguecontroller.CreateDialogueWindow(targetID);
		var dialog = _root.dialoguecontroller.m_DialogueWindows[targetID];
		if (dialog) {
			dialog._visible = true;
			var currentQuest = dialog.m_QuestGiver.m_AvailableQuests[0];
			var quest:com.GameInterface.Quest = new com.GameInterface.Quest();
			quest.m_ID = 2318;	// 99999
			quest.m_MissionName = "Test Quest";
			quest.m_MissionDesc = "This is a test quest.  This shows up in the quest description.";
			quest.m_MissionType = _global.Enums.MainQuestType.e_Story;
			/*
			e_Action
			e_Sabotage
			e_Investigation
			e_Item
			e_Group
			e_Lair
			e_PVP
			e_Raid
			e_Scenario
			e_Massacre
			e_Story
			e_StoryRepeat
			*/
			quest.m_SortOrder = 3;
			quest.m_Xp = 0;
			quest.m_Cash = 0;
			quest.m_TierMax = 0;
			quest.m_HasCooldown = true;
			quest.m_IsRepeatable = currentQuest.m_IsRepeatable;
			quest.m_HasCompleted = true;
			quest.m_IsLocked = currentQuest.m_IsLocked;
			quest.m_HideIfLocked = currentQuest.m_HideIfLocked;
			// quest.m_CooldownExpireTime = 0;
			quest.m_Tiers = currentQuest.m_Tiers;
			quest.m_CurrentTask = currentQuest.m_CurrentTask;
			quest.m_Rewards = currentQuest.m_Rewards;
			quest.m_OptionalRewards = currentQuest.m_OptionalRewards;
			quest.m_SolvedText = currentQuest.m_SolvedText;
			quest.m_DLCTag = currentQuest.m_DLCTag;
			quest.m_CanLocateOnMap = currentQuest.m_CanLocateOnMap;
			
			dialog.m_QuestGiver.m_AvailableQuests.push(quest);
			//dialog.Clear();
			dialog.DrawMissions();
	        dialog.m_DynelName = dialog.attachMovie("DynelName", "m_DynelName", dialog.getNextHighestDepth());
			dialog.m_DynelName.m_Name.textField.text = LDBFormat.Translate(dialog.m_Dynel.GetName());

			if (target.HasDialogue())
			{
				dialog.DrawDialogue();
			}
			//dialog.CheckHide();
			dialog.m_MissionClip.selector_2318.m_Button.onRelease = function() {
				_root.fifo.SlotShowFIFOMessage("onRelease Function Overridden");
			}
		}
	}

	function URLTest()
	{
		// URL test using visible browser
		com.GameInterface.DistributedValueBase.SetDValue("WebBrowserStartURL", "file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/index.html");
        com.GameInterface.DistributedValueBase.SetDValue("web_browser", true);
		_global.setTimeout(this, "URLTest2", 2000);
	}
	
	function URLTest2()
	{
		_root.webbrowser.m_Window.m_Content.m_Browser.SignalStartLoadingURL.Connect(BrowserOnLoading, this);
	}

	function PostTest()
	{

		var tier_post = this.AddTier("browser", "Post Test.");
		
		var missionStatuses = DistributedValue.GetDValue("ug_missions");
		tier_post.SetURL("file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/posttest.html?xml=" + escape(missionStatuses));
		return;

		var xmlText;
		var thisList = this;
		var missionListXML:XML = new XML();
		missionListXML.ignoreWhite = true;
		missionListXML.load('Untold/MissionList.xml');
		missionListXML.onLoad = function(success) {
			if (success) {
				xmlText = missionListXML.toString();
			} 
			else {
				xmlText = "List XML Failure";
			}
			tier_post.SetURL("file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/posttest.html?xml=" + escape(xmlText));
		};
	}

	function EscTest()
	{
		this.MessageBox("Esc pressed.");
	}

	function RotateCharacter()
	{
		var charIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
		charIF.SetRotation(1);
		charIF = null;
	}

	function URLStream()
	{
            try {
				var url = "file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/loadrequest.html";
                m_Browser = new com.GameInterface.Browser.Browser(6, 100, 100);
                m_Browser.SignalStartLoadingURL.Connect(BrowserOnLoading, this);
                m_Browser.SignalBrowserShowPage.Connect(BrowserOnShow, this);
                m_Browser.OpenURL(url);
				this.MessageBox("State1: " + m_Browser.GetBrowserState().toString());
				// _global.m_MissionDebugWindow.contentTextField.text += "\nURL: " + url + "\n";
            } catch(e) {
				_global.m_MissionDebugWindow.contentTextField.text += "Browser error\n";
            }

/*			var url2 = "http://www.mbs-intl.com/tsw/scroll/smile.ogg";
			m_Browser2 = new com.GameInterface.Browser.Browser(7, 100, 100);
			m_Browser2.OpenURL(url2);
			this.MessageBox("State2:" + m_Browser2.GetBrowserState().toString());*/
	}

	public function BrowserOnLoading(results) {
		try {
			if (results.toString() != "ERROR") {
				//this.MessageBox(unescape(results.toString()));
				_global.m_MissionDebugWindow.contentTextField.text = "results: " +unescape(results.toString()) + "\n";
			}
		} catch(e) {
			com.GameInterface.LogBase.Error("Service.OnCallbackRecieved", e);
			_global.m_MissionDebugWindow.contentTextField.text += "OnLoading Error\n";
		}
	}
	public function BrowserOnShow() {
		try {
			_global.m_MissionDebugWindow.contentTextField.text += "OnShow\n";
		} catch(e) {
			com.GameInterface.LogBase.Error("Service.OnCallbackRecieved", e);
			_global.m_MissionDebugWindow.contentTextField.text += "OnShow Error\n";
		}
	}

/*	function HackLocation()
	{
		var tier_1 = this.AddTier("location", "Location hack");
		tier_1.SetLocation(1000, 0, 0, 0, 1, 1);

//		var evalTest = "tier_1.m_Player.m_Name";
//		this.MessageBox(eval(evalTest));
 
 		var tier_2 = this.AddTier("move", "Location hack.");
		tier_2.SetPlayField(1000);
		tier_2.AddPath(290, 31, 325, 0);
		tier_2.AddPath(290, 31, 325, 5000);
//		tier_2.AddPath(292, 31, 320, 5000);
		//tier_2.AddPath(284.3, 34.5, 230, 10000);
//		tier_2.AddPath(-185, 100, 100, 1000);
//		tier_2.AddPath(1000, 100, 100, 30000);
//		tier_2.AddPath(1200, 200, 100, 20000);
//		tier_2.AddPath(675, 85, 636, 5000);
//		tier_2.AddPath(675, 120, 636, 30000);
//		tier_2.AddPath(675, 120, 636, 30000);
		//tier_2.AddPath(-1, -1, -1, 2000);

		var tier_3 = this.AddTier("location", "Location hack");
		tier_3.SetLocation(1200, 0, 0, 0, 1, 1);
	}*/
	
	function arrayTest()
	{
		var aTest = new Array();
		aTest.push(["Basic", 0, 0]);
		aTest.push(["Personal", 2, 1]);
		aTest.push(["Scroll", 50, 2]);
		this.MessageBox("join:" + aTest.join());
		this.MessageBox("toString:" + aTest.toString());

//		var aTest2= new Array("Basic", "Personal", "Scroll");
//		this.MessageBox(aTest2.join());
	}

	function ConvertMissionToXML()
	{
//		var xmlTest = new BasicTraining();
		//var xmlTest = new APersonalMatter();
//		var xmlTest = new TheScroll();
//		xmlTest.ConvertToXML();

		/*var mission = new BaseMission();
		var ap_xml = new XML();
		ap_xml.ignoreWhite = true;
		ap_xml.load("Untold/BasicTraining.xml");
		ap_xml.onLoad = function(sucess) {
			if (sucess) {
				_global.missionXML = ap_xml;
				mission.LoadXML(ap_xml);
				mission.StartMission();
			}
		};
		*/
	}

	function ListNPCs()
	{
		for (var prop in _root.interactioncontroller.m_InteractionDynels) {
//			_root.fifo.SlotShowFIFOMessage("Dynel:" + _root.interactioncontroller.m_InteractionDynels[prop].GetID(), 0);

			var dynel = Character.GetDynel(_root.interactioncontroller.m_InteractionDynels[prop].GetID());
			if (dynel.IsNPC() == true) {
				_root.fifo.SlotShowFIFOMessage("NPC:" + dynel.GetName(), 0);
			}
		}
	}

	function ListDynels()
	{
		for (var prop in _root.interactioncontroller.m_InteractionDynels) {
			_root.fifo.SlotShowFIFOMessage("Dynel:" + _root.interactioncontroller.m_InteractionDynels[prop].GetName(), 0);
		}
	}

	function TrackVicinity() 
	{
		VicinitySystem.SignalDynelEnterVicinity.Connect( SlotEnterVicinity, this );
	    VicinitySystem.SignalDynelLeaveVicinity.Connect( SlotLeaveVicinity, this );
	}

	function SlotEnterVicinity( dynelID)
	{
		var dynel = Character.GetDynel(dynelID);
		//if (dynel.IsNPC() == true) {
			//_root.fifo.SlotShowFIFOMessage("Enter Vicinity:" + dynel.GetName(), 0);
		//}
		//if (dynel.GetName()) {
			_global.m_MissionDebugWindow.contentTextField.text = "Enter Vicinity:" + dynel.GetName() + "\n" + _global.m_MissionDebugWindow.contentTextField.text;
		//}
	}

	function SlotLeaveVicinity( dynelID)
	{
		var dynel = Character.GetDynel(dynelID);
//		if (dynel.IsNPC() == true) {
			//_root.fifo.SlotShowFIFOMessage("Leave Vicinity:" + dynel.GetName(), 0);
//		}
		//if (dynel.GetName()) {
			_global.m_MissionDebugWindow.contentTextField.text = "Leave Vicinity:" + dynel.GetName() + "\n" + _global.m_MissionDebugWindow.contentTextField.text;
		//}
	}

	function ScryFIFO(messageArray:Array)
	{
		_root.fifo.SlotShowFIFOMessage("Scry:" + messageArray.toString(), 0);
	}

	function testDValue()
	{
		_global.m_MissionDebugWindow.contentTextField.text = DistributedValue.GetDValue("CharacterCreationActive").toString();	
		m_CharacterCreationIF = null;
	}

	function SetPlayerPosition(x, y, z, rotation) {
		SetPosition(m_Player.m_Character, x, y, z, rotation);
	}

	function SetTargetPosition(x, y, z, rotation) {
		var targetID = m_Player.m_Character.GetDefensiveTarget();
		var target = Character.GetCharacter(targetID);
		if (target) {
			SetPosition(target, x, y, z, rotation);
		}
	}

	function GetTargetPosition() {
		var targetID = m_Player.m_Character.GetDefensiveTarget();
		var target = Character.GetCharacter(targetID);
		var position = target.GetPosition();
		_global.m_MissionDebugWindow.contentTextField.text = "X: " + position.x.toString();
		_global.m_MissionDebugWindow.contentTextField.text += "\nY: " + position.y.toString();
		_global.m_MissionDebugWindow.contentTextField.text += "\nZ: " + position.z.toString();
		_global.m_MissionDebugWindow.contentTextField.text += "\nRotation: " + target.GetRotation().toString();
		Chat.SetChatInput("Y: " + position.y.toString());
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
	}

	public function CamTest()
	{
		com.GameInterface.Game.Camera.PlaceCamera(506 + m_CamAdjust, 410, 404 + m_CamAdjust, 511, 408, 401,0, 1, 0);
		m_CamAdjust = m_CamAdjust + .1;
		if (m_CamAdjust < 20){
			//setTimeout(CamTest, 1); 
			_global.setTimeout(this, "CamTest", 10);
		}
		else {
	//		com.GameInterface.Game.Camera.SignalCinematicActivated.Emit();
	//		var charcreate = new com.GameInterface.CharacterCreation.CharacterCreation(false);
	//		charcreate.ExitCharacterCreation();
	//		var m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation( m_IsSurgery);
	//		m_CharacterCreationIF.ResetSurgeryData();
	//        UnloadClip();
	
	//		GUIFramework.SFClipLoaderBase.ClipUnloaded("");
			var m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
			// m_CharacterCreationIF.ExitCharacterCreation();
			this.MessageBox("Camera complete.");
			com.GameInterface.DistributedValueBase.SetDValue("CharacterCreationActive", false);	
		}	
	}


	function GetPlayerID()
	{
		// _global.m_MissionDebugWindow.contentTextField.text += "\nID: " + m_Player.m_Character.GetID().toString();
		com.GameInterface.Chat.SetChatInput(m_Player.m_Name + ": " + m_Player.m_Character.GetID().toString());
		// SuperJenius: 50000:100664898
		// SalvatorisTui: 50000:100789340
		// GirlJenius: 50000:50488415
	}

	function LoadTest()
	{
/*		var thisMission = this;
		var my_lv:LoadVars = new LoadVars();
		my_lv.onData = function(src:String) {
			if (src == undefined) {
				thisMission.MessageBox("Error loading content.");
				return;
			}
			thisMission.MessageBox(src);
		};
		my_lv.load("http://www.mbs-intl.com/tsw/scroll/test.txt", my_lv, "GET");	*/
	}
	
	function SoundTest()
	{
		/*try
		{
				var thisMission = this;
				var my_sound:Sound = new Sound();
				my_sound.onLoad = function(success:Boolean):Void {
					if (success == true) {
						thisMission.MessageBox("Sound Loaded");
						my_sound.start();
					}
					else
					{
						thisMission.MessageBox("Sound loading failed");
					}
				};
				my_sound.loadSound("chaplin_smile.mp3", false);
		}
		catch (myError:Error) { 
			this.MessageBox(myError); 
		}*/
	}
	
	private function WearCloth():Void 
	{
		m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
	
			for (var i=0; i<30; i++) {
				m_CharacterCreationIF.UnWearCloth( i );
			}
			m_CharacterCreationIF.ResetSurgeryData();
	
			DistributedValue.SetDValue("CharacterCreationActive", true);	
			DistributedValue.SetDValue("CharacterCreationActive", false);	
	
			m_CharacterCreationIF.WearCloth( 2, 0 );
			m_CharacterCreationIF = null;
	}
	
	private function HomePage():Void 
	{
		var m_HomePage = this.AddTier("browser","Home Page");
		m_HomePage.SetURL("file:///D:/Games/The%20Secret%20World/Data/Gui/Customized/Flash/Untold/index.html",
						   "Untold Stories of The Secret World", false);
		m_HomePage.SetURLTracking(true);
		m_HomePage.onURLChange = function(results) {
			this.MessageBox(unescape(results.toString()));
			_global.m_MissionDebugWindow.contentTextField.text = "results: " +unescape(results.toString()) + "\n";
		}
		m_HomePage.StartTier();
	}
	
	private function CharCreation():Void 
	{
		com.GameInterface.Log.Warning("Sandbox", "This is a test");
		DistributedValue.SetDValue("CharacterCreationActive", true);	
		var characterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation(true);
		characterCreationIF = null;
		DistributedValue.SetDValue("CharacterCreationActive", false);	
	}
	
	private function ErrorTest():Void 
	{
		try {
			ULog.Error("Before Error");
			//throw new Error("Sandbox Test Error"); 
			var obj:Object = new Object();
			var errTest = obj.a;
			ULog.Error("After Error");
		}
		catch (myError) {
			ULog.Error("Sandbox Error caught: " + myError.toString());
		}
	}
	
	private function AbortTest():Void 
	{
		// Press Esc to exit cinematic
		// You have to use entire public path to abort function
		var abortFunction = "_root.untold\\untold.m_MissionListWindow.m_Content.m_CurrentMission.EscTest";
		com.GameInterface.Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_ESC, abortFunction, _global.Enums.Hotkey.eHotkeyDown, 0);
	}
	
}

