// Web Browser Tier
// Opens browser and completes tier when browser is closed.
import com.GameInterface.Browser.Browser;

class BrowserTier extends BaseTier
{
	
	public var m_URL:String;
	public var m_BrowserTitle:String;
	public var m_HideAddress:Boolean;
	public var m_Width:Number;
	public var m_Height:Number;
	public var m_TrackURL:Boolean;
	
	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("BrowserTier.LoadXML()");
		this.SetURL(tierNode.attributes.url, tierNode.attributes.browserTitle, (tierNode.attributes.hideAddress == "true"), 
					Number(tierNode.attributes.width), Number(tierNode.attributes.height));
	}

	public function SetURL(url:String, browserTitle:String, hideAddress:Boolean, width:Number, height:Number)
	{
		//ULog.Info("BrowserTier.SetURL(): title=" + browserTitle);
		m_URL = url;
		m_BrowserTitle = browserTitle;
		m_HideAddress = hideAddress;
		m_Width = width;
		m_Height = height;
	}
	
	public function SetURLTracking(trackURL:Boolean)
	{
		//ULog.Info("BrowserTier.SetURLTracking()");
		m_TrackURL = trackURL;
	}

	public function StartTier()
	{
		ULog.Info("BrowserTier.StartTier() title=" + m_BrowserTitle);
		var url = m_URL;
		// If size specified, defer loading until browser resized
        if (m_Width || m_Height)
		{
			url = "about:blank";
		}
		com.GameInterface.DistributedValueBase.SetDValue("WebBrowserStartURL", url);
        com.GameInterface.DistributedValueBase.SetDValue("web_browser", true);
		this.AdjustBrowser(this, m_URL, m_BrowserTitle, m_HideAddress, m_Width, m_Height);
		if (m_TrackURL == true) {
			this.TrackURL();
		}
	}
	
	public function AdjustBrowser(thisTier)
	{
		if (_root.webbrowser.m_Window)
		{
			ULog.Info("BrowserTier.AdjustBrowser()");
			var browserWindow = _root.webbrowser.m_Window;
			var loader = browserWindow.m_Content.m_Loader;
			browserWindow._visible = false;
			if (thisTier.m_BrowserTitle)
			{
				browserWindow.SetTitle(thisTier.m_BrowserTitle);
			}
			if (thisTier.m_HideAddress)
			{
				browserWindow.m_Content.m_AddressBar._visible = false;
				browserWindow.m_Content.m_BackButton._visible = false;
				browserWindow.m_Content.m_ForwardButton._visible = false;
			}
			
			// Changing the size is a pain
			// You have to change individual elements, or else things get scaled and skewed.
			var width = thisTier.m_Width;
			var height = thisTier.m_Height;
			if (width || height)
			{
				var visibleRect = Stage["visibleRect"];
				if (width)
				{
					width = Math.min(width, visibleRect.width - 10); // don't exceed resolution
					var widthDiff = loader._width - width;
					loader._width = width;
					browserWindow.m_Background._width -= widthDiff;
					browserWindow.m_DropShadow._width -= widthDiff;
					browserWindow.m_CloseButton._x -= widthDiff;
				}
				if (height)
				{
					height = Math.min(height, visibleRect.height - 80); // don't exceed resolution
					var heightDiff = loader._height - height;
					loader._height = height;
					browserWindow.m_Background._height -= heightDiff;
					browserWindow.m_DropShadow._height -= heightDiff;
				}
				com.GameInterface.DistributedValueBase.SetDValue("WebBrowserStartURL", thisTier.m_URL);
				browserWindow.m_Content.configUI();
				// Fix scaling after reloaded
				loader._xscale = 100;
				loader._yscale = 100;
				
				// Center window at new size
				_x = visibleRect.x;
				_y = visibleRect.y;
				browserWindow._x = Math.round((visibleRect.width / 2) - (browserWindow.m_Background._width / 2));
				browserWindow._y = Math.round((visibleRect.height / 2) - (browserWindow.m_Background._height / 2));
			}

			browserWindow._visible = true;
				
			// End tier when browser closed
			//browserWindow.SignalClose.Connect(thisTier.EndTier, thisTier);
			thisTier.CheckBrowser(thisTier);
		}
		else 
		{
			// May take a bit for the browser to load. Keep trying until available.
			setTimeout(thisTier.AdjustBrowser, 10, thisTier);
		}
	}
	
	// SignalClose doesn't fire if browser closed via keyboard (Esc, B), so check if it is still open
	public function CheckBrowser(thisTier)
	{
		if (_root.webbrowser.m_Window) {
			setTimeout(thisTier.CheckBrowser, 100, thisTier);
		}
		else {
			thisTier.EndTier();
		}
	}

	// Track when URL changes
	// This is the only way the browser can send data back to TSW
	public function TrackURL()
	{
		var browserSignal = _root.webbrowser.m_Window.m_Content.m_Browser.SignalStartLoadingURL;
		if (browserSignal) {
			ULog.Info("BrowserTier.TrackURL(): Tracking SignalStartLoadingURL");
			browserSignal.Connect(onURLChanged, this);
			//_root.webbrowser.m_Window.m_Content.m_Browser.SignalStartLoadingURL.Connect(onURLChanged, this);
		}
		else {
			// Browser takes a bit to load, so retry until it is loaded
			// Use _global.setTimeout to avoid scoping issues
			_global.setTimeout(this, "TrackURL", 100);
		}
	}
	
	// Event fires when URL changed
	public function onURLChanged(url)
	{
		ULog.Info("BrowserTier.onURLChanged(): " + url);
	}
	
	public function AbortTier()
	{
		ULog.Info("BrowserTier.AbortTier()");
		// Close browser
		com.GameInterface.DistributedValueBase.SetDValue("WebBrowserStartURL", "");
		com.GameInterface.DistributedValueBase.SetDValue("web_browser", false);
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'url="' + m_URL + '" ';
		if (m_BrowserTitle) {
			tierXML += 'browserTitle="' + m_BrowserTitle.split("\n").join("\\n") + '" ';
		}
		if (m_HideAddress) {
			tierXML += 'hideAddress="' + m_HideAddress.toString() + '" ';
		}
		if (m_Width) {
			tierXML += 'width="' + m_Width.toString() + '" ';
		}
		if (m_Height) {
			tierXML += 'height="' + m_Height.toString() + '" ';
		}
		tierXML += ' />\n'
		return tierXML;
	}

}
