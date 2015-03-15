// World Story Browser
// When icon is clicked, browser is opened to specified URL

class WorldStoryBrowser extends WorldStoryBase
{
	public var m_BrowserTier;
	
	public function LoadXML(storyNode:XMLNode)
	{
		super.LoadXML(storyNode);
		this.SetURL(storyNode.attributes.url, Number(storyNode.attributes.width), Number(storyNode.attributes.height));
	}

	public function SetURL(url:String, width:Number, height:Number)
	{
		//_root.fifo.SlotShowFIFOMessage("WorldStoryBrowser.SetURL()");
		m_BrowserTier = new BrowserTier();
		m_BrowserTier.m_Player = m_Player;
		var browserTitle = m_StoryTitle + "\n" + m_SubTitle;
		var hideAddress = true;
		m_BrowserTier.SetURL(url, browserTitle, hideAddress, width, height);
	}
	
	public function PerformAction()
	{
		// Open browser
		m_BrowserTier.StartTier();
	}
	
	public function Cleanup()
	{
		m_BrowserTier.AbortTier();
		m_BrowserTier = undefined;
		super.Cleanup();
	}
}