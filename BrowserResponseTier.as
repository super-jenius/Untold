// Web Browser Reponse Tier
// This tier is added automatically by the Browser tier when a response is required
// The player won't be able to advance to the next tier until the correct reponse is received

class BrowserResponseTier extends BaseTier
{
	public var m_Complete:Boolean;
	
	public function BrowserResponseTier()
	{
		m_SkipPrev = true;
		m_NoBell = true;
	}
	
	public function StartTier()
	{
		if (m_Complete == true) {
			EndTier();
		}
	}
}