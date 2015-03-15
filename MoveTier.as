// Move Character Tier
// *** SetPosition removed from API. This tier no longer works.
// Moves character from one location to another over the specified time
// Movement is only client-side, but can glitch out, so best to go back to starting location
// Multiple paths can be done in one tier
// Tier ends when all paths are complete, but you can specify that a tier end early.
// All paths will still complete, but another tier can begin while movement is in progress.

class MoveTier extends BaseTier
{
	
	public var m_PlayField:Number;
	public var m_Paths:Array;
	
	public var m_CurrentField;
	public var m_CurrentPath;
	public var m_CurrentX;
	public var m_CurrentY;	// this is height
	public var m_CurrentZ;
	public var m_OriginalX;
	public var m_OriginalY;
	public var m_OriginalZ;
	public var m_PositionNo;
	public var m_IntervalCnt;
	public var m_IntervalX;
	public var m_IntervalY;
	public var m_IntervalZ;
	public var m_MovementBlocker;
	public var m_AbortingTier;
	public var m_Aborted;

	public function MoveTier()
	{
		m_Paths = new Array();
	}

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("MoveTier.LoadXML()");
		this.SetPlayField(Number(tierNode.attributes.playField));
		for (var i = 0; i < tierNode.childNodes.length; i++) {
			var pathNode:XMLNode = tierNode.childNodes[i];
			if (pathNode) {
				this.AddPath(Number(pathNode.attributes.x), Number(pathNode.attributes.y), Number(pathNode.attributes.z), Number(pathNode.attributes.duration));
			}
		}
	}

	// Movement will only occur if you are in the correct playfield
	public function SetPlayField(playField:Number)
	{
		//ULog.Info("MoveTier.SetPlayField(): playField=" + playField.toString());
		m_PlayField = playField;
	}

	public function AddPath(x:Number, y:Number, z:Number, duration:Number)
	{
		// If no duration specified, use 1 millisecond
		if (!duration) 
		{
			duration = 1;
		}
		m_Paths.push([x, y, z, duration]);	

		_global.m_MissionDebugWindow.contentTextField.text = "AddPath(): " + m_Paths.length + "\n";
	}
	
	public function StartTier()
	{

		ULog.Info("MoveTier.StartTier()");
		// Block movement or character could end up in an unpredicatble place
		//m_MovementBlocker = new com.GameInterface.MovementBlocker();
		m_CurrentPath = 0;
		m_AbortingTier = false;
		m_Aborted = false;

		var position = m_Player.m_Character.GetPosition();
		m_CurrentX = position.x;
		m_CurrentY = position.y;
		m_CurrentZ = position.z;

		m_OriginalX = position.x;
		m_OriginalY = position.y;
		m_OriginalZ = position.z;
		
		//_global.m_MissionDebugWindow.contentTextField.text += "StartTier()\n";
		// Movement is only client-side, but can glitch out and end up in weird places
		// Take focus off main screen and block movement. Hope that's enough.
		//Selection.setFocus(_global.m_MissionDebugWindow.focusButton);
		//m_MovementBlocker = new com.GameInterface.MovementBlocker();
		
		// If you're in the middle of a jump or fall, this causes problems
		// Wait a second for jump to finish
		//_global.setTimeout(this, "StartNextPath", 1000);

		this.StartNextPath();
	}
	
	public function StartNextPath()
	{
		//_global.m_MissionDebugWindow.contentTextField.text += "StartNextPath()\n";

		// Make sure in correct playfield
		m_CurrentField = m_Player.m_Character.GetPlayfieldID();
		if (m_CurrentField == m_PlayField) {

			var path = m_Paths[m_CurrentPath];
			if (path) {
				var x = path[0];
				var y = path[1];
				var z = path[2];
				var duration = path[3];
				
				// -99 means move on to next tier, but continue paths while next tier runs
				if (x == -99) {
					this.EndTier();
					m_CurrentPath++;
					this.StartNextPath();
				}
				else {
					// -1 means original coordinates
					if (x == -1) {
						x = m_OriginalX;
					}
					if (y == -1) {
						y = m_OriginalY;
					}
					if (z == -1) {
						z = m_OriginalZ;
					}
	
					m_IntervalCnt = duration / 10;
					m_IntervalX = (x - m_CurrentX) / m_IntervalCnt;
					m_IntervalY = (y - m_CurrentY) / m_IntervalCnt;
					m_IntervalZ = (z - m_CurrentZ) / m_IntervalCnt;
					
					m_PositionNo = 1;
					//_global.m_MissionDebugWindow.contentTextField.text += "Before MoveCharacter()\n";
					for (var i=0; i<m_IntervalCnt; i++){
						_global.setTimeout(this, "MoveCharacter", i * 10);
					}
					//this.MoveCharacter();
				}
			}
			else {
				//_global.m_MissionDebugWindow.contentTextField.text += "No more paths.\n";
				
				// All paths complete. Give focus and movement back.
				m_MovementBlocker.ReleaseBlock();
				Selection.setFocus(null);
				this.EndTier();
			}
		}
	}

	public function MoveCharacter() 
	{

		if (m_Aborted == true) {
			return;
		}
		
		if (m_AbortingTier == true) {
			m_Aborted = true;
			m_CurrentX = m_OriginalX;
			m_CurrentY = m_OriginalY;
			m_CurrentZ = m_OriginalZ;
		}
		else {
			m_CurrentX += m_IntervalX;
			m_CurrentY += m_IntervalY;
			m_CurrentZ += m_IntervalZ;
		}

		var position = new com.GameInterface.MathLib.Vector3();
		position.x = m_CurrentX
		position.y = m_CurrentY
		position.z = m_CurrentZ
		// SetPosition removed from API. This tier no longer works.
		//m_Player.m_Character.SetPosition(position);

		// Next position
		m_PositionNo ++;
		if (m_PositionNo <= m_IntervalCnt) {
//			_global.setTimeout(this, "MoveCharacter", 10);
		}
		else {
			// Path complete, start next path
			m_CurrentPath++;
			this.StartNextPath();
		}
	}

	public function AbortTier()
	{
		ULog.Info("MoveTier.AbortTier()");
		// Abort further position changes and go back to original position
		m_AbortingTier = true;
		this.EndTier();
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'playField="' + m_PlayField.toString() + '" ';
		tierXML += '>\n'
		for (var i = 0; i < m_Paths.length; i++) {
			var path = m_Paths[i];
			tierXML += '\t\t<path ' 
				+ 'x="' + path[0].toString() + '" ' 
				+ 'y="' + path[1].toString() + '" ' 
				+ 'z="' + path[2].toString() + '" ' 
				+ 'duration="' + path[3].toString() + '" ' 
				+ '/>\n';
		}
		tierXML += "\t</tier>\n"
		return tierXML;
	}
	
}
