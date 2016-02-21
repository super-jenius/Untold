// Location Tier
// Completes when player arrives within range of designated coordinates
import com.Utils.ID32;
import com.GameInterface.Quests;

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

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("LocationTier.LoadXML()");
		this.SetLocation(Number(tierNode.attributes.playField), Number(tierNode.attributes.x), Number(tierNode.attributes.y), 
						 Number(tierNode.attributes.z), Number(tierNode.attributes.distance), Number(tierNode.attributes.yDistance),
						 tierNode.attributes.waypointName);
	}

	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number, waypointName:String)
	{
		//ULog.Info("LocationTier.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;	// distance from 
		m_yDistance = yDistance;	// distance 
		m_WaypointName = waypointName;
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
		if (m_CurrentField == m_PlayField) {
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
			// The API doesn't let you create a new waypoint, but you can hijack an existing one
			// This only works if there is currently an active mission that uses a waypoint
			for(var id:String in _root.waypoints.m_CurrentPFInterface.m_Waypoints) {
				// Get first existing waypoint then exit loop
				m_Waypoint = _root.waypoints.m_CurrentPFInterface.m_Waypoints[id];
				break;
			}
			if (m_Waypoint == undefined)
			{
				// Start a side mission that contains a waypoint
				// 3176 - Bullets for Andy
				// 2918 - Trespassers
				// 2893 - Mission persons (multiple waypoints)
				// Make sure mission slot available
				if (!missionStarted && _root.missiontracker.m_MissionBar["Slot5"].m_MissionTrackerItem == undefined) {
					Quests.AcceptQuestFromQuestgiver( 3176, new ID32(0, 0));
					// Notify user
					_root.fifo.SlotShowFIFOMessage("Untold Stories started a side mission to enable waypoints.");
					ShowWaypoint(true);
					return;
				}
				// There is no active mission/waypoint, so don't try again
				m_WaypointName = undefined;
				// Notify user
				//_root.fifo.SlotShowFIFOMessage("TIP: Untold Stories can display a waypoint if an official mission that uses a waypoint is currently in progress.");
				return;
			}
			// Make changes to waypoint
			m_Waypoint.m_Label = m_WaypointName; // empty string is ok
			m_Waypoint.m_WorldPosition.x = m_X;
			m_Waypoint.m_WorldPosition.y = m_Y;
			m_Waypoint.m_WorldPosition.z = m_Z;
			m_Waypoint.m_IsScreenWaypoint = true;
			m_Waypoint.m_IsStackingWaypoint = false;
			m_Waypoint.m_Radius = m_Distance;
			m_Waypoint.m_Color = 255;	// blue looks different than existing waypoints
			m_Waypoint.m_WaypointState = 0;	// visible
			m_Waypoint.m_WaypointType = _global.Enums.WaypointType.e_RMWPPvPDestination;
			
			// Remove existing waypoint or there will be duplicate references
			_root.waypoints.m_CurrentPFInterface.SignalWaypointRemoved.Emit(m_Waypoint.m_Id);
			// Signal waypoint interface to show changes
			_root.waypoints.m_CurrentPFInterface.SignalWaypointAdded.Emit(m_Waypoint.m_Id);
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
