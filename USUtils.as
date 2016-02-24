import mx.data.encoders.Bool;
// Untold Stories Utilities

class USUtils
{

	// Evaluate {{expression}} contained in templatestring
	// You can only get the value of a property or variable. You can't evaluate any expression.
	// Example: My name is {{player.m_Name}}.
	public static function TextMerge(template:String, escapeResult:Boolean)
	{
		// Initial check to see if template contains an expressions
		var expStart = template.indexOf("{{");
		var expEnd = template.indexOf("}}");
		if (expStart == -1 || expEnd == -1) {
			// No tags so return
			return template;
		}
		
		// Define variables that can be used in template
		var untold = _root["untold\\untold"];
		var version = untold.m_VerNo;
		var mission:BaseMission = untold.m_MissionListWindow.m_Content.m_CurrentMission;
		var tier:BaseTier = mission.m_CurrentTier;
		var player:PlayerInfo = mission.m_Player;
		var m_Player:PlayerInfo = player;	// backwards compatibility
		
		while (expStart >= 0 && expEnd >= 0) {
			var expBraces = template.substring(expStart, expEnd + 2);
			var expression = expBraces.substr(2, expBraces.length - 4); 
			// _root path to property required
			//var expression = "_root.untold\\untold.m_MissionListWindow.m_Content.m_CurrentMission." + expression;
			var expResult = eval(expression);
			// If valid expression, update line
			if (expResult) {
				if (escapeResult == true) {
					expResult = escape(expResult.toString());
				}
				template = template.split(expBraces).join(expResult.toString());
				// Check for more expressions
				expStart = template.indexOf("{{");
				expEnd = template.indexOf("}}");
			} 
			else {
				// Bad expression
				break;
			}
		}
		
		return template;
	}
	
}