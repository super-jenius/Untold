// Location Tier
// Location Tier
// Completes when player arrives within range of designated coordinates
import com.Utils.ID32;
import com.GameInterface.Quests;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Game.Camera;

class LocationTier extends BaseTier
{
	
	public var m_PlayField:Number;
	public var m_X:Number;
	public var m_Y:Number;
	public var m_Z:Number;
	public var m_Distance:Number;
	public var m_yDistance:Number;
	public var m_IntervalID;
	public var m_Lore:Boolean = false;

	public var m_CurrentField;
	public var m_CurrentX;
	public var m_CurrentY;	// this is height
	public var m_CurrentZ;
	public var m_xDist;
	public var m_yDist;
	public var m_zDist;
	public var m_WaypointName;
	private var m_Waypoint;
	public var m_Ghost;

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("LocationTier.LoadXML()");
		this.SetLocation(Number(tierNode.attributes.playField), Number(tierNode.attributes.x), Number(tierNode.attributes.y), 
						 Number(tierNode.attributes.z), Number(tierNode.attributes.distance), Number(tierNode.attributes.yDistance),
						 tierNode.attributes.waypointName, Boolean(tierNode.attributes.ghost));
	}

	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number, waypointName:String, ghost:Boolean)
	{
		//ULog.Info("LocationTier.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;	// distance from 
		m_yDistance = yDistance;	// distance 
		m_WaypointName = waypointName;
		m_Ghost = (ghost ? ghost : false);
	}

	public function StartTier()
	{
		ULog.Info("LocationTier.StartTier(): m_PlayField=" + m_PlayField.toString() + ", x=" + m_X.toString() + ", y=" + m_Y.toString() + ", z=" + m_Z.toString());
		m_IntervalID = setInterval(this, "CheckLocation", 200);
	}

	public function CheckLocation():Boolean
	{
		m_CurrentField = m_Player.m_Character.GetPlayfieldID();
		var debugWindow = _global.m_MissionDebugWindow;
		if (m_Lore == false && debugWindow._visible == true)
		{
			debugWindow.contentTextField.text = "Playfield: " + m_CurrentField.toString();
		}
		// Make sure we are in correct playfield
		// Also check if player should be ghosting (in anima form)
		if (m_CurrentField == m_PlayField && m_Ghost == m_Player.m_Character.IsGhosting()) {
			var position = m_Player.m_Character.GetPosition();
			m_CurrentX = position.x;
			m_CurrentY = position.y;
			m_CurrentZ = position.z;
			m_xDist = Math.abs(m_CurrentX - m_X);
			m_yDist = Math.abs(m_CurrentY - m_Y);
			m_zDist = Math.abs(m_CurrentZ - m_Z);

			// Don't show location in debug window if this is lore (WorldStory).  Otherwise, we get a bunch of updates all at once.
			if (m_Lore == false && debugWindow._visible == true)
			{
				debugWindow.contentTextField.text += "\nX: " + m_CurrentX.toString();
				debugWindow.contentTextField.text += "\nY: " + m_CurrentY.toString();
				debugWindow.contentTextField.text += "\nZ: " + m_CurrentZ.toString();
				debugWindow.contentTextField.text += "\nRotation: " + m_Player.m_Character.GetRotation().toString();
				debugWindow.contentTextField.text += "\nX Distance: " + Math.abs(m_CurrentX - m_X).toString();
				debugWindow.contentTextField.text += "\nY Distance: " + Math.abs(m_CurrentY - m_Y).toString();
				debugWindow.contentTextField.text += "\nZ Distance: " + Math.abs(m_CurrentZ - m_Z).toString();
			}
			// See if we are in range of coordinates
			if (Math.abs(m_CurrentX - m_X) <= m_Distance && Math.abs(m_CurrentZ - m_Z) <= m_Distance && Math.abs(m_CurrentY - m_Y) <= m_yDistance) {
				clearInterval(m_IntervalID);
				ULog.Info("LocationTier.CheckLocation(): Location found");
				this.EndTier();
				return true;
			}
			// Check if waypoint should be shown
			this.ShowWaypoint();
		}
		return false;
	}

	public function AbortTier()
	{
		ULog.Info("LocationTier.AbortTier()");
		clearInterval(m_IntervalID);
		this.EndTier();
	}
	
	public function EndTier()
	{
		// Reset waypoints
		if (m_Waypoint)
		{
			_root.waypoints.m_CurrentPFInterface.SignalWaypointRemoved.Emit(m_Waypoint.m_Id);
			m_Waypoint = undefined;
			_root.waypoints.m_CurrentPFInterface.SignalPlayfieldChanged.Emit(m_Player.m_Character.GetPlayfieldID());
		}
		super.EndTier();
	}

	public function ShowWaypoint(missionStarted:Boolean)
	{
		// Check if waypoint should be shown
		if (m_WaypointName && m_Waypoint == undefined && m_Lore == false)
		{
			var customWaypoint = false;
			// The API doesn't let you create a new waypoint, so create a custom waypoint that tracks approximate position
			m_Waypoint = new com.GameInterface.Waypoint();
			m_Waypoint.m_Id = new ID32(0, 0);
			m_Waypoint.m_WorldPosition = new com.GameInterface.MathLib.Vector3();
			_root.waypoints.m_CurrentPFInterface.m_Waypoints["0:0"] = m_Waypoint;
				
			// Make changes to waypoint
			m_Waypoint.m_Label = m_WaypointName; // empty string is ok
			m_Waypoint.m_WorldPosition.x = m_X;
			m_Waypoint.m_WorldPosition.y = m_Y;
			m_Waypoint.m_WorldPosition.z = m_Z;
			m_Waypoint.m_IsScreenWaypoint = true;
			m_Waypoint.m_IsStackingWaypoint = false;
			m_Waypoint.m_Radius = m_Distance;
			m_Waypoint.m_Color = 255;	// blue looks different than existing waypoints
			m_Waypoint.m_WaypointState = _global.Enums.QuestWaypointState.e_WPStateActive;	// visible
			m_Waypoint.m_WaypointType = _global.Enums.WaypointType.e_RMWPPvPDestination;
			m_Waypoint.m_CollisionOffsetX = 0;
			m_Waypoint.m_CollisionOffsetY = 0;
			m_Waypoint.m_MinViewDistance = 0;
			m_Waypoint.m_MaxViewDistance = 0;
			m_Waypoint.m_DistanceToCam = 0;
			
			// Remove existing waypoint or there will be duplicate references
			_root.waypoints.m_CurrentPFInterface.SignalWaypointRemoved.Emit(m_Waypoint.m_Id);
			// Signal waypoint interface to show changes
			_root.waypoints.m_CurrentPFInterface.SignalWaypointAdded.Emit(m_Waypoint.m_Id);
			
			this.UpdateWaypoint();
		}
	}
	
	// Update custom waypoint
	public function UpdateWaypoint()
	{
		if (m_Waypoint) {
			var cam:Vector3 = Camera.m_Pos;
			var pos:Vector3 = m_Waypoint.m_WorldPosition;
			var visibleRect = Stage["visibleRect"];
			
			// Calculate distance
			// Taken from http://www.calculatorsoup.com/calculators/geometry-solids/distance-two-points.php
			var distance = Math.sqrt(Math.pow(pos.x - cam.x, 2) + Math.pow(pos.y - cam.y, 2) + Math.pow(pos.z - cam.z, 2));
			distance = Math.abs(Math.round(distance));
			m_Waypoint.m_DistanceToCam = distance;

			// Calculate horizontal positiion on screen
			var camAngle = Camera.m_AngleY;			
			var charPos: Vector3 = this.m_Player.m_Character.GetPosition( _global.Enums.AttractorPlace.e_Ground );
			var deltaz = pos.z - charPos.z;
			var deltax = pos.x - charPos.x;
			var hAngle = (Math.atan2(deltax, deltaz));			
			var waypointAngle = camAngle + hAngle;
			var multiplier = waypointAngle + 1
			var screenx = (visibleRect.width / 2) * multiplier;
			m_Waypoint.m_ScreenPositionX = screenx;
			
			// Calculate vertical position on screen
			// Loose approximation based on character position, because vertical camera angle is not provided by API
			var deltay = pos.y - charPos.y;
			var vAngle = Math.abs((Math.atan2(deltaz, deltay)));
			var vmultiplier = ((vAngle + 1)/Math.PI);
			var screeny = Math.max(Math.min((visibleRect.height / 2) * vmultiplier, visibleRect.height * .9), 0);
			m_Waypoint.m_ScreenPositionY = screeny;			

			_root.waypoints.UpdateScreenWaypoints();
			_global.setTimeout(this, "UpdateWaypoint", 30);
		}
	}

	
	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'playField="' + m_PlayField.toString() + '" '
			+ 'x="' + m_X.toString() + '" '
			+ 'y="' + m_Y.toString() + '" '
			+ 'z="' + m_Z.toString() + '" '
			+ 'distance="' + m_Distance.toString() + '" '
			+ 'yDistance="' + m_yDistance.toString() + '" '
			+ '/>\n'
		return tierXML;
	}

	// Just for testing
	function SetPosition(x, y, z) {
		var position = new com.GameInterface.MathLib.Vector3();
		position.x = x;
		position.y = y;
		position.z = z;
		// SetPosition removed from API. This no longer works.
		//m_Player.m_Character.SetPosition(position);
//		m_Player.m_Character.ReInitialize();
	}

}
