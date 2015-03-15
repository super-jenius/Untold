// Dialog Tier
// Displays dialog using subtitles and ends when dialog is complete.
import flash.filters.DropShadowFilter;
import com.GameInterface.Game.Camera;
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.GameInterface.AccountManagement;

class DialogTier extends BaseTier
{
	public var m_Dialog:Array;
	public var m_CurrentLineNo;
	public var m_WordsPerSec:Number;
	public var m_Cinematic:Boolean;
	public var m_Audio;
	
	public function DialogTier()
	{
		m_Dialog = new Array();
		m_WordsPerSec = 3;
	}
	
	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("DialogTier.LoadXML()");
		if (tierNode.attributes.speed) {
			this.m_WordsPerSec = Number(tierNode.attributes.speed);
		}
		for (var i = 0; i < tierNode.childNodes.length; i++) {
			var dialogNode:XMLNode = tierNode.childNodes[i];
			if (dialogNode) {
				var dialogFaction = dialogNode.attributes.faction;
				var dialogGender = dialogNode.attributes.gender;
				// Check faction and gender requirements
				if ((dialogFaction == undefined || dialogFaction == "" || dialogFaction.toLowerCase() == m_Player.m_Faction.toLowerCase()) &&
					(dialogGender == undefined || dialogGender == "" || dialogGender.toLowerCase() == m_Player.m_Gender.toLowerCase()))
				{					
					var dialogLine;
					if (dialogNode.attributes.type == "audio") {
						dialogLine = "#audio#";
						this.AddAudio(dialogNode.attributes.url, Boolean(dialogNode.attributes.preload), Number(dialogNode.attributes.volume), Boolean(dialogNode.attributes.loop), Boolean(dialogNode.attributes.stop));
					} else {
						switch (dialogNode.attributes.type) {
						case "fadeout" :
							dialogLine = "#fadeout#";
							break;
						case "fadein" :
							dialogLine = "#fadein#";
							break;
						case "dialog" :
							dialogLine = dialogNode.attributes.line;
							break;
						}
						this.AddLine(dialogLine, Number(dialogNode.attributes.duration));
					}
				}
			}
		}
	}

	// Add line of dialog and how long to display
	// Specify duration to override default time
	public function AddLine(dialogLine:String, duration:Number)
	{
		// Evaluate {{expression}} contained in string
		// You can only get the value of a property or variable. You can't evaluate any expression.
		var expStart = dialogLine.indexOf("{{");
		var expEnd = dialogLine.indexOf("}}");
		while (expStart >= 0 && expEnd >= 0) {
			var expBraces = dialogLine.substring(expStart, expEnd + 2);
			var expression = expBraces.substr(2, expBraces.length - 4); 
			// _root path to property required
			var expression = "_root.untold\\untold.m_MissionListWindow.m_Content.m_CurrentMission." + expression;
			var expResult = eval(expression);
			// If valid expression, update line
			if (expResult) {
				dialogLine = dialogLine.split(expBraces).join(expResult.toString());
				// Check for more expressions
				expStart = dialogLine.indexOf("{{");
				expEnd = dialogLine.indexOf("}}");
			} 
			else {
				// Bad expression
				break;
			}
		}
		
		// If no duration specified, calculated default
		if (!duration) 
		{
			var numWords = dialogLine.split(" ").length;
			duration = Math.max((numWords/m_WordsPerSec) + 1, 2);	// calculate words per second, 2 second minimum
		}
		m_Dialog.push([dialogLine, duration]);	
	}
	
	public function AddAudio(audioURL, preload, volume, loop, stop)
	{
		m_Dialog.push(["#audio#", audioURL, preload, volume, loop, stop]);	
	}
	
	public function StartTier()
	{
		ULog.Info("DialogTier.StartTier()");
		// Press Esc to exit dialog
		// You have to use entire public path to abort function
		//var abortFunction = "_root.untold\\untold.m_MissionListWindow.m_Content.m_CurrentMission.m_CurrentTier.AbortTier";
		var abortFunction = "_root.untold\\untold.m_CurrentTier.AbortTier";
		com.GameInterface.Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_ESC, abortFunction, _global.Enums.Hotkey.eHotkeyDown, 0);

		m_TierEnded = false;
		m_CurrentLineNo = -1;
		this.ProcessDialog();
	}
	
	public function AbortTier()
	{
		ULog.Info("DialogTier.AbortTier()");
		// Clear dialog array
		//m_Dialog.splice(0);
		//m_Dialog.push(["", 0]);
		m_CurrentLineNo = m_Dialog.length;
		//Show2DText("", 0, 0, 0.8, 3, "center", .5, .5);
		_root.ugFade.SlotFadeScreen( true, 0);
		this.EndTier();
	}
	
	public function EndTier()
	{
		// Make sure EndTier isn't called more than once, such as when aborted
		if (m_TierEnded == false)
		{
			ULog.Info("DialogTier.EndTier()");
			com.GameInterface.Input.RegisterHotkey(_global.Enums.InputCommand.e_InputCommand_ESC, "", _global.Enums.Hotkey.eHotkeyDown, 0);
			if (m_Audio) {
				m_Audio.StopAudio();
			}
			super.EndTier();
		}
	}
	
	public function ProcessDialog()
	{
	
		// End tier if logging out
		if (AccountManagement.GetInstance().GetLoginState() <> _global.Enums.LoginState.e_LoginStateInPlay) {
			this.EndTier();
			return;
		}

//		var currentLine = m_Dialog.shift();
		m_CurrentLineNo++;
		var currentLine = m_Dialog[m_CurrentLineNo];
		// End tier if you dialog is complete, or you zone or log out in the middle of dialog (menu is gone)
		// if (currentLine && _root.mainmenuwindow) {
		if (currentLine) {
			var lineText = currentLine[0];
			var lineDelay = currentLine[1];
			var thisTier = this;
			if (lineText == "#fadeout#"){
				_root.ugFade.SlotFadeScreen( false, lineDelay );
				_global.setTimeout(this, "ProcessDialog", (lineDelay * 1000) - 1000);
			} else if (lineText == "#fadein#"){
				_root.ugFade.SlotFadeScreen( true, lineDelay );
				_global.setTimeout(this, "ProcessDialog", 500);
			} else if (lineText == "#audio#"){
				this.PlayAudio(currentLine[1], currentLine[2], currentLine[3], currentLine[4], currentLine[5]);
				_global.setTimeout(this, "ProcessDialog", 10);
			} else {
				Show2DText(lineText, lineDelay, 0, 0.8, 3, "center", .5, .5);
			}
		} else {
			//this.MessageBox("Dialog complete.");
			this.EndTier();
		}
	}
	
	public function PlayAudio(audioURL, preload, volume, loop, stop)
	{
		if (m_Audio == undefined) { 
			m_Audio = new AudioPlayer();
		}
		m_Audio.PlayAudio(audioURL, preload, volume, loop, stop);
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		if (m_TierType == "cinematic") {
			return tierXML;
		}
		if (m_WordsPerSec <> 3) {
			tierXML += 'speed="' + m_WordsPerSec.toString() + '" ';
		}
		tierXML += '>\n'
		for (var i = 0; i < m_Dialog.length; i++) {
			var currentLine = m_Dialog[i];
			switch (currentLine[0]) {
			case "#fadeout#" :
				tierXML += '\t\t<dialog type="fadeout" duration="' + currentLine[1].toString() + '" />\n';
				break;
			case "#fadein#" :
				tierXML += '\t\t<dialog type="fadein" duration="' + currentLine[1].toString() + '" />\n';
				break;
			default :
				// Most lines don't have duration, so do manually after conversion
				tierXML += '\t\t<dialog type="dialog" line="' + currentLine[0].split("\n").join("\\n") + '" ';
				// If line is blank or credits, then add duration
				if (currentLine[0] == "" || currentLine[0].indexOf("-") == 0) {
					tierXML += 'duration="' + currentLine[1].toString() + '" ';
				}
				tierXML += '/>\n';
				break;
			}
		}
		tierXML += "\t</tier>\n"
		return tierXML;
	}
	
	// A slightly modified version of ProjectUtils.Show2DText
	// This function uses the FUNCOM User Interface Source Code License
	/// Shows a text on the screen, behind the gui. It will show onscreen for the duration given.
	/// A handle is returned so you can removed before the time is up via Remove2DText.
	private function Show2DText( text:String, duration:Number, x:Number, y:Number, style:Number, align:String, fadeIn:Number, fadeOut:Number, transition:String ) : Number
	{
		var uid = _root.UID();
		// SJ: Make padding larger so text wraps before going near edges
		var padding:Number = 200;
		//var padding:Number = 60;
		var clipName = "Layer2DText_" + uid;
		
		Log.Info2("", "Show2DText(clipName=" + clipName + ", x=" + x + ", y=" + y +")");      
		
		var visibleRect = Stage["visibleRect"];
		var availableWidth = visibleRect.width - (padding * 2);
		
		var letterbox = com.GameInterface.Game.Camera.m_CinematicStripHeight;
		
		var clip:MovieClip = GUIFramework.SFClipLoader.CreateEmptyMovieClip(clipName, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop, 0 );
		
		// Scale related to default screensize.
		var s_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
		var scale = s_ResolutionScaleMonitor.GetValue();
		clip._xscale *= scale;
		clip._yscale *= scale;
			
		var language:String = DistributedValue.Create("Language").GetValue();
		
		clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);
		
		// Set style and text.
		var font:String = "_StandardFont";
		var size:Number = 11;
		var color:String = "#FFFFFF";
		var bold:Boolean = false;
		
		/*
		 *  The following conditional improves the display of incidental subtitles 
		 *  in non english languages:  http://jira.funcom.com/browse/TSW-98448
		 * 
		 */
		
		var incidentalPadding:Number = 0;
		
		if (language != "en" && style == 2)
		{
			style = 4;
			incidentalPadding = 620;
		}
		
		/*
		 * 
		 */
			
		switch( style )
		{
			case 1:
				size = 44;
			break;
			case 2:
				font = "_StandardFont";
				bold = true;
				size = 33;
				color = "#DDDDDD";
			break;
			case 3: // cinematic subtitles
				font = "_StandardFont";
				bold = true;
				size = 32;
			break;
			case 4: // ingame subtitles
				y = letterbox == 0 ? 1.0 - (100 * scale / visibleRect.height) : 0.95;
				font = "_StandardFont";
				bold = true;
				size = 22;
			break;
		}
		
		text = "<p align='"+align+"'><font face='"+font+"' size='"+size+"' color='"+color+"' >" + text + "</font></p>";
		
		var shadow:DropShadowFilter = new DropShadowFilter( 52, 70, 0x000000, 0.7, 2, 2, 2, 3, false, false, false );
		
		clip.label.filters = [shadow];
		clip.label.multiline = true;
		clip.label.wordWrap = true;
		clip.label.autoSize = align;
		
		var clipX:Number = visibleRect.x + padding; 
		var labelWidth:Number = visibleRect.width - (padding * 2)
		
		if (x > 0)
		{
			padding = 10; /// we just need a bit of padding, resetting it
			if (align == "left")
			{
				clipX = visibleRect.width * x;
				labelWidth = visibleRect.width - ((visibleRect.width * x) + padding);
			}
			else if (align == "right")
			{
				labelWidth = (visibleRect.width * x) -padding;
				clipX = padding;
			}
			else if (align == "center")
			{
				var position:Number = (visibleRect.width * x);
				clipX = padding;
				
				if (x > 0.5)
				{
					position = visibleRect.width - (visibleRect.width * x);
				}
				
				labelWidth = ((position - 10 ) * 2) - incidentalPadding;
				clipX = (visibleRect.width * x) - ((labelWidth - 10) * 0.5);
			}
		}	
		
		
		// don't eat mouse input
		clip.label.selectable = false;
		
		// label stuff
		labelWidth *=  (1 / scale);
		clip.label._width = labelWidth;
		clip._x = clipX
		clip.label.html = true;
		clip.label.htmlText = text;
		
		clip._y = letterbox + (y*(visibleRect.height-letterbox*2)) + visibleRect.y;
		clip.startTime = getTimer();
		
		// draw above origo, so multiple lines are moved up instead of down into the black cinematic bars
		clip.label._y = -clip.label._height;
		
		// Start the fade in transition and setup fade out timer.
		duration *= 1000;
		fadeIn *= 1000;
		fadeOut *= 1000;
		if( true /*transition == "Fade"*/ )
		{
		 clip._alpha = 0;
		  
		  // SJ: Add reference to this object so event handler can call back
		  var thisTier = this;
		  clip.onEnterFrame = function()
		  {
			var time = getTimer();
			
			if( time > this.startTime + duration )
			{
			  // Done.
			  this.UnloadClip();
			  //SJ: Process next line
			  thisTier.ProcessDialog();
			}
			else if( time < this.startTime + fadeIn )
			{
				// Fade in.
				this._alpha = 100*(time - this.startTime)/fadeIn;
			}
			else if( time > this.startTime + duration - fadeOut )
			{
				// Fade out.
				this._alpha = 100*(fadeOut-(time - (this.startTime + duration - fadeOut)))/fadeOut;
			}
			else
			{
				this._alpha = 100;
			}
		  }
		  /* */
		}
		
		return uid;
	}

}