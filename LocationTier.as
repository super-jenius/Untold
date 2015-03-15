// Location Tier
// Completes when player arrives within range of designated coordinates

class LocationTier extends BaseTier
{
	
	public var m_PlayField:Number;
	public var m_X:Number;
	public var m_Y:Number;
	public var m_Z:Number;
	public var m_Distance:Number;
	public var m_yDistance:Number;
	public var m_IntervalID;

	public var m_CurrentField;
	public var m_CurrentX;
	public var m_CurrentY;	// this is height
	public var m_CurrentZ;
	public var m_xDist;
	public var m_yDist;
	public var m_zDist;

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("LocationTier.LoadXML()");
		this.SetLocation(Number(tierNode.attributes.playField), Number(tierNode.attributes.x), Number(tierNode.attributes.y), 
						 Number(tierNode.attributes.z), Number(tierNode.attributes.distance), Number(tierNode.attributes.yDistance));
	}

	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number)
	{
		//ULog.Info("LocationTier.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;	// distance from 
		m_yDistance = yDistance;	// distance 
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
		debugWindow.contentTextField.text = "Playfield: " + m_CurrentField.toString();
		// Make sure we are in correct playfield 
		if (m_CurrentField == m_PlayField) {
			var position = m_Player.m_Character.GetPosition();
			m_CurrentX = position.x;
			m_CurrentY = position.y;
			m_CurrentZ = position.z;
			m_xDist = Math.abs(m_CurrentX - m_X);
			m_yDist = Math.abs(m_CurrentY - m_Y);
			m_zDist = Math.abs(m_CurrentZ - m_Z);

			debugWindow.contentTextField.text += "\nX: " + m_CurrentX.toString();
			debugWindow.contentTextField.text += "\nY: " + m_CurrentY.toString();
			debugWindow.contentTextField.text += "\nZ: " + m_CurrentZ.toString();
			debugWindow.contentTextField.text += "\nRotation: " + m_Player.m_Character.GetRotation().toString();
			debugWindow.contentTextField.text += "\nX Distance: " + Math.abs(m_CurrentX - m_X).toString();
			debugWindow.contentTextField.text += "\nY Distance: " + Math.abs(m_CurrentY - m_Y).toString();
			debugWindow.contentTextField.text += "\nZ Distance: " + Math.abs(m_CurrentZ - m_Z).toString();
			
			// See if we are in range of coordinates
			if (Math.abs(m_CurrentX - m_X) <= m_Distance && Math.abs(m_CurrentZ - m_Z) <= m_Distance && Math.abs(m_CurrentY - m_Y) <= m_yDistance) {
				clearInterval(m_IntervalID);
				ULog.Info("LocationTier.CheckLocation(): Location found");
				this.EndTier();
				return true;
			}
		}
		return false;
	}

	public function AbortTier()
	{
		ULog.Info("LocationTier.AbortTier()");
		clearInterval(m_IntervalID);
		this.EndTier();
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
