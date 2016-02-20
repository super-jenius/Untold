// Apply animations/emotes to characters or NPCs
import com.GameInterface.Game.Character;

class AnimationTier extends BaseTier
{
	
	public var m_Animations:Array;
	public var m_AnimTarget:String;
	public var m_TargetQty:Number;
	public var m_PlayField:Number;
	public var m_X:Number;
	public var m_Y:Number;
	public var m_Z:Number;
	public var m_Distance:Number;	// distance from X,Z
	public var m_yDistance:Number;	// distance from Y
	public var m_AnimTargets:Object;
	public var m_AnimNo:Number;
	
	public function AnimationTier()
	{
		m_SkipPrev = true;
		m_NoBell = true;
	}
	
	public function LoadXML(tierNode:XMLNode)
	{
		ULog.Info("AnimationTier.LoadXML()");
		// Set targets
		this.SetTarget(tierNode.attributes.animTarget, tierNode.attributes.targetQty);
						
		// Set location for NPCs to target
		this.SetLocation(tierNode.attributes.playField, tierNode.attributes.x, tierNode.attributes.y, tierNode.attributes.z, 
						tierNode.attributes.distance, tierNode.attributes.yDistance);
		
		// Add animation
		for (var i = 0; i < tierNode.childNodes.length; i++) {
			var animNode:XMLNode = tierNode.childNodes[i];
			if (animNode) {
				var animName:String = animNode.attributes.name;
				var duration:Number = Number(animNode.attributes.duration);
				this.AddAnimation(animName, duration);
			}
		}
		ULog.Info("AnimationTier.LoadXML(): Complete");
	}
	
	public function SetTarget(animTarget:String, targetQty:Number)
	{
		m_AnimTarget = animTarget.toLowerCase();
		m_TargetQty = targetQty;
	}
	
	public function SetLocation(playField:Number, x:Number, y:Number, z:Number, distance:Number, yDistance:Number)
	{
		//ULog.Info("AnimationTier.SetLocation(): playField=" + playField.toString() + ", x=" + x.toString() + ", y=" + y.toString() + ", z=" + z.toString());
		m_PlayField = playField;
		m_X = x;
		m_Y = y;
		m_Z = z;
		m_Distance = distance;
		m_yDistance = yDistance;
	}
	
	public function AddAnimation(animName:String, duration:Number) 
	{
		if (m_Animations == undefined) {
			m_Animations = new Array();
		}
		m_Animations.push([animName, duration]);	
	}
	
	public function StartTier()
	{
		ULog.Info("AnimationTier.StartTier()");

		this.SelectTargets();
		if (m_AnimTargets != undefined) {
			m_AnimNo = 0;
			this.ProcessAnimations();
		}

		// End tier as soon as animations are started
		this.EndTier();
	}
	
	public function SelectTargets()
	{
		// Select targets for animations
		m_AnimTargets = new Object();
		var selector:Selector = new Selector();
		switch (m_AnimTarget) 
		{
		case undefined:
			break;
		case "player" :
			m_AnimTargets["player"] = selector.SelectPlayer();
			break;
		case "target" :
			m_AnimTargets["target"] = selector.SelectFriendlyTarget();
			break;
		default :
			selector.SetLocation(m_PlayField, m_X, m_Y, m_Z, m_Distance, m_yDistance);
			m_AnimTargets = selector.SelectNPCs(m_AnimTarget, m_TargetQty);
			break;
		}
	}

	
	public function ProcessAnimations()
	{
		ULog.Info("AnimationTier.ProcessAnimations()");
		var currentAnim = m_Animations[m_AnimNo];
		if (currentAnim != undefined) {
			var animName:String = currentAnim[0];
			var duration:Number = currentAnim[1];
			if (isNaN(duration) == true)
			{
				duration = 0;
			}
			var target:Character;
			for (var prop in m_AnimTargets) {
				target = m_AnimTargets[prop];
				ULog.Info("AnimationTier.ProcessAnimations(): prop=" + prop + " target=" + target.GetName() + " animName=" + animName + " duration=" + duration);
				target.SetBaseAnim(animName);
			}
		}
		m_AnimNo++;
		if (m_AnimNo < m_Animations.length) {
			_global.setTimeout(this, "ProcessAnimations", (duration * 1000));
		}
	}
	
}