// Untold Stories Mission System
// Created by Super Jenius
import com.GameInterface.DistributedValue;
import com.GameInterface.Browser.Browser;

var m_MissionListWindow;
var m_MissionDebugWindow;
var m_HideSubtitles;
//var m_CustomWindow;
var m_Interval;
var m_Sandbox;
var m_HomePage;
var m_VerNo;
var m_WorldStories;
var m_BackgroundBrowser;
var m_CurrentTier;
var m_MissionXML;
//var m_LooksRDBXML;
var m_AudioPlayer;
var m_LoadLocal;

function onLoad()
{

	// Set version here for each release
	m_VerNo = "3.3";
	
	// Turn on info logging?
	ULog.m_LogInfo = false;
	ULog.Info("Version " + m_VerNo);
	ULog.Info("Untold.Onload()");
	// Show sandbox button?
	m_Sandbox = false;
	// Load local mission window instead of home page?
	m_LoadLocal =  false;
	// Is debug window visible?
	m_MissionDebugWindow._visible = false;
	m_MissionDebugWindow.focusButton._visible = false;
	m_MissionDebugWindow.titleTextField.text = "Mission Debug";
	m_MissionDebugWindow._x = 10;
	m_MissionDebugWindow._y = 150;
	_global.m_MissionDebugWindow = m_MissionDebugWindow;
	
	// Hide subtitles in dialog/cinematics?
	m_HideSubtitles = false;

	// Scale windows according to Miscellaneous Scaling option
	var guiScale = com.GameInterface.DistributedValueBase.GetDValue("GUIScaleHUD");
	m_MissionDebugWindow._xscale = guiScale;
	m_MissionDebugWindow._yscale = guiScale;
	m_CustomWindow._xscale = guiScale;
	m_CustomWindow._yscale = guiScale;
	
//    m_MissionDebugWindow.SignalClose.Connect( SlotCloseDebugWindow, this );
	m_MissionDebugWindow.closeButton.addEventListener("click", this, "CloseDebugWindow");
	
	// Position mission window
	m_CustomWindow._visible = false;
	m_CustomWindow.focusButton._visible = false;
    var visibleRect = Stage["visibleRect"];
    m_CustomWindow._x = visibleRect.width - ((m_CustomWindow._width + 225) * guiScale/100);
    m_CustomWindow._y = 22 * guiScale/100;	// visibleRect.height * .15
//    m_CustomWindow.SignalClose.Connect( SlotCloseCustomWindow, this );
//	_global.m_CustomWindow = m_CustomWindow;
	m_CustomWindow.closeButton.addEventListener("click", this, "CloseCustomWindow");

	// Hook into main menu as soon as it is available
	this.hookMenu();

	// _root.fadetoblack doesn't work in cinematics (not sure why), so we create our own instance
	if (_root.ugFade == undefined) {
		GUIFramework.SFClipLoader.LoadClip("FadeToBlack.swf", "ugFade" ,true, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop);
		// So we don't have two faders when signaled by game
		com.Utils.GlobalSignal.SignalFadeScreen.Disconnect( SlotFadeScreen, _root.ugFade );
	}

    // Setup Mission List Window
	m_MissionListWindow._visible = false;
	m_MissionListWindow.SetTitle("LOCAL MISSIONS " + m_VerNo);
    m_MissionListWindow.SetPadding(10);
    m_MissionListWindow.SetContent( "MissionListContent" );
    m_MissionListWindow.SignalClose.Connect( SlotCloseMissionList, this );
    //m_MissionListWindow.ShowFooter( true );
	m_MissionListWindow.ShowCloseButton( true );
    m_MissionListWindow.ShowResizeButton( false );
    m_MissionListWindow.ShowStroke( false );
    //m_MissionListWindow.SetSize( 350, 250 );
	m_MissionListWindow.m_Content._xscale = guiScale;
	m_MissionListWindow.m_Content._yscale = guiScale;
    
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    m_MissionListWindow._x = visibleRect.width / 2 - m_MissionListWindow._width / 2;
    m_MissionListWindow._y = visibleRect.height / 2 - m_MissionListWindow._height / 2;
	
	this.LoadWorldStories();
	//this.LoadLooksRDBXML();
}

// Hook into main menu as soon as it is available
function hookMenu()
{
	if (_root.mainmenuwindow.m_MenuItems)
	{
		_root.mainmenuwindow.UpdateMainMenuItems = addMenu();
		// Menu gets reloaded when you zone, so regularly check if it exists
		m_Interval = setInterval(checkMenu, 1000);
	}
	else if (_root["meeehrui\\meeehrui-topbar"].MainMenu)
	{
		// Add to Meeehr TopBar menu
		addMTBMenu();
	}
	else 
	{
		setTimeout(hookMenu, 100);
	}
}

function checkMenu()
{
	if (!_root.mainmenuwindow.m_CustomJournalButton)
	{
		clearInterval(m_Interval);
		m_UnloadCnt++;
		hookMenu();
	}
}

// Add Community Missions to main menu
function addMenu()
{
	ULog.Info("Untold.addMenu()");
	var menu = _root.mainmenuwindow;
	menu.attachMovie("JournalButton", "m_CustomJournalButton", menu.getNextHighestDepth(), {_x:menu.m_MenuItems[0]._x, _visible:false});
	menu.SetupMenuItem(menu.m_CustomJournalButton, "mission_journal_window", "", "Untold Stories");

	menu.m_CustomJournalButton.addEventListener("click", this, "CustomJournalHandler");
	
	// Put new button above Settings and Exit
	menu.m_MenuItems[menu.m_MenuItems.length - 3] = menu.m_CustomJournalButton;
	menu.m_MenuItems[menu.m_MenuItems.length - 2] = menu.m_SettingsButton;
	menu.m_MenuItems[menu.m_MenuItems.length - 1] = menu.m_ExitButton;
}

// Add to Meeehr TopBar menu
function addMTBMenu()
{
	ULog.Info("Untold.addMTBMenu()");
	var menu = _root["meeehrui\\meeehrui-topbar"].MainMenu;
	var button = menu.MenuButton4;
	var newButton = button.duplicateMovieClip('MenuButtonUS', menu.getNextHighestDepth(), { _y:(button._height * 20) + 5 } );
	newButton.attachMovie("JournalIcon", "Icon", menu.getNextHighestDepth(), {_x:button.Icon._x, _y:button.Icon._y, _width:button.Icon._width, _height:button.Icon._height});

	//_root.fifo.SlotShowFIFOMessage("New 1: " + newButton.Text.text, 0);
	newButton.Text.text = "Untold Stories";	
	newButton.Active._visible = false;
	newButton.Hotkey._visible = false;
	newButton.distributedValue = undefined;
	newButton.onPress = function() {
		//_root.fifo.SlotShowFIFOMessage("newButton.onPress", 0);
		_root["meeehrui\\meeehrui-topbar"].CloseMenu();
		newButton.Highlight._visible = false;
		CustomJournalHandler();
	}
	//button.Icon.duplicateMovieClip('newButton.Icon', menu.getNextHighestDepth());;
	//_root.fifo.SlotShowFIFOMessage("New 2: " + newButton.Text.text, 0);
	// Move other buttons down
	var i = 20;
	while (menu["MenuButton" + i.toString()]) {
		var moveButton = menu["MenuButton" + i.toString()];
		moveButton._y += moveButton._height;
		i++;
	}
}

function CustomJournalHandler()
{
	_root.mainmenuwindow.MainMenuReleaseEventHandler();
	if (m_LoadLocal == true) {
		this.LocalMissionList();
	} else {
		this.HomePage();
	}
	//_global.m_MissionDebugWindow.contentTextField.text += "Title: " + m_HomePage.m_BrowserTitle + "\n";
}

// Load home page in browser
function HomePage()
{
	//var baseURL = "file:///E:/Games/Secret%20World%20Legends/Data/Gui/Custom/Flash/Untold/web/index.html";
	var baseURL = "http://untoldworld.azurewebsites.net/";
	ULog.Info("Untold.HomePage()");
	
	// Make sure any existing browser is closed
	com.GameInterface.DistributedValueBase.SetDValue("WebBrowserStartURL", "");
	com.GameInterface.DistributedValueBase.SetDValue("web_browser", false);

	var playerInfo = new PlayerInfo();

	// var missionStatuses = DistributedValue.GetDValue("ug_missions");
	var missionStatuses = m_MissionListWindow.m_Content.m_MissionStatus.LoadStatus();
	var worldEnabled = DistributedValue.GetDValue("us_world");
	var position = playerInfo.m_Character.GetPosition();
	var selector:Selector = new Selector();
	var targetPos = selector.SelectFriendlyTarget().GetPosition();
	m_HomePage = new BrowserTier();
//	m_HomePage.SetURL("http://www.google.com", "Google", true);
	var homePage = baseURL + "?version=" + escape(m_VerNo)
					  + "&playerName=" + escape(playerInfo.m_Name) 
					  + "&playerID=" + escape(playerInfo.m_CharacterID.toString()) 
					  + "&playerFaction=" + escape(playerInfo.m_Faction) 
					  + "&playerGender=" + escape(playerInfo.m_Gender) 
					  + "&worldStories=" + escape(worldEnabled.toString())
					  + "&playfield=" + escape(playerInfo.m_Character.GetPlayfieldID())
					  + "&x=" + escape(position.x.toString())
					  + "&y=" + escape(position.y.toString())
					  + "&z=" + escape(position.z.toString())
					  + "&targetX=" + escape(targetPos.x.toString())
					  + "&targetY=" + escape(targetPos.y.toString())
					  + "&targetZ=" + escape(targetPos.z.toString())
					  + "&statusXML=" + escape(missionStatuses);
	m_HomePage.SetURL(homePage, "UNTOLD STORIES OF THE SECRET WORLD " + m_VerNo, true);
	m_HomePage.SetURLTracking(true);
	m_HomePage.onURLChanged = URLChanged;
	m_HomePage.onTierComplete = function() {
		m_HomePage = null;
	}
	m_HomePage.StartTier();
}

function URLChanged(newurl:String) {
	var url = unescape(newurl);
	//ULog.Info("Untold.URLChanged(): " + url);
	if (url.slice(0, 15) == "data:,missionID")
	{
		// Load mission
		m_HomePage.AbortTier();
		var xmlStart = url.indexOf("<?xml");
		var missionID = url.slice(16, xmlStart);
		ULog.Info("Untold.URLChanged(): missionID " + missionID);
		var missionXML = url.slice(xmlStart);
		m_MissionXML = missionXML;
		m_MissionListWindow.m_Content.LoadWebMission(missionID, missionXML);
	} 
	else if ((url.slice(0, 18) == "data:,resetMission")) {
		// Reset mission
		m_HomePage.AbortTier();
		ULog.Info("Untold.URLChanged(): " + url);
		var missionID = url.slice(19);
		m_MissionListWindow.m_Content.ResetWebMission(missionID);
		// Restart home page. "this" doesn't work here, so have to call public interface.
		HomePage();
		// Not sure why you don't need to call using _root. Must be a public function.
		//_root["untold\\untold"].HomePage();
	}
	else if ((url.slice(0, 19) == "data:,localMissions")) {
		// Local Mission Launcher
		m_HomePage.AbortTier();
		ULog.Info("Untold.URLChanged(): " + url);
		LocalMissionList();
		//_root["untold\\untold"].LocalMissionList();
	}
	else if ((url.slice(0, 18) == "data:,worldStories")) {
		// Enable/disable world stories
		m_HomePage.AbortTier();
		ULog.Info("Untold.URLChanged(): " + url);
		var worldEnabled = url.slice(19);
		DistributedValue.SetDValue("us_world", worldEnabled);
		LoadWorldStories();
	}
}

// Enable/disable World Stories based on setting.
function LoadWorldStories()
{
	var worldEnabled = DistributedValue.GetDValue("us_world");
	// Default to enabled
	if (worldEnabled == undefined) {
		worldEnabled = "true";
		DistributedValueBase.SetDValue("us_world", "true");
	}

	// Load World Stories
	if (worldEnabled.toString() == "true") {
		// If not already loaded, then instantiate
		if (m_WorldStories == undefined) {
			m_WorldStories = new WorldStories();
			_root.fifo.SlotShowFIFOMessage("Untold Stories Lore Enabled", 0);
		}
	} else {
		// Unload if loaded
		if (m_WorldStories != undefined) {
			m_WorldStories.Unload();
			m_WorldStories = undefined;
			_root.fifo.SlotShowFIFOMessage("Untold Stories Lore Disabled", 0);
		}
	}
}

function LocalMissionList()
{
	ULog.Info("Untold.LocalMissionList()");
	m_MissionListWindow._visible = !m_MissionListWindow._visible;
	if (m_MissionListWindow._visible == true) {
		m_MissionListWindow.m_Content.m_DeleteButton.visible = m_Sandbox;
		m_MissionListWindow.m_Content.LoadMissions();
	}
}

function SlotCloseMissionList()
{
	m_MissionListWindow._visible = false;
}

function CloseDebugWindow()
{
	m_MissionDebugWindow._visible = false;
}

function CloseCustomWindow()
{
	m_MissionListWindow.m_Content.PromptAbortMission();
}

// Maintain single reference to background browser
// Facebook is unused by game. Using it for background download, so it doesn't interfere with other MODs.
// I previously used the Help/Petition browser instance, because I thought the Facebook browser caused lag.
// It turns out that with any browser, you have to set a size, or 20 FPS lag will occur until the browser object is released.
// The game automatically lowers game volume while browser is loaded, but there is nothing we can do about it.
// I tried using com.GameInterface.UtilsBase.AttenuateGameSounds(), but sound only comes back to full volume when browser is released.
function GetBackgroundBrowser()
{
	// Make sure current Help window is closed
	//DistributedValue.SetDValue("petition_browser", false);
	if (m_BackgroundBrowser == undefined) {
		//m_BackgroundBrowser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Browser, 800, 600); 
		m_BackgroundBrowser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Facebook, 800, 600);
		//m_BackgroundBrowser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Petition, 800, 600);
	}
	//_root.fifo.SlotShowFIFOMessage("Untold.GetBackgroundBrowser(): " + m_BackgroundBrowser);
	// Signal if Help window is opened
	//_root.mainmenuwindow.m_PetitionMonitor.SignalChanged.Connect(SlotPetitionState, this);
	return m_BackgroundBrowser;
}

/*
function SlotPetitionState()
{
	// If Help/Petition window opened, then release browser
	if (DistributedValue.GetDValue("petition_browser") == true) {
		_root.fifo.SlotShowFIFOMessage("Untold.SlotPetitionState()");
		this.ReleaseBackgroundBrowser();
	}
}
*/

function ReleaseBackgroundBrowser()
{
	if (m_BackgroundBrowser) {
		m_BackgroundBrowser.Stop();
		m_BackgroundBrowser.CloseBrowser();
		m_BackgroundBrowser = undefined;
		//_root.mainmenuwindow.m_PetitionMonitor.SignalChanged.Disconnect(SlotPetitionState, this);
		//_root.fifo.SlotShowFIFOMessage("Untold.ReleaseBackgroundBrowser()");
	}
}

function GetAudioPlayer()
{
	if (m_AudioPlayer == undefined) {
		m_AudioPlayer = new AudioPlayer();
	}
	return m_AudioPlayer;
}

// Load LooksRDB.xml file
// This works, but looking up IDs adds too much to mission load time.
/*function LoadLooksRDBXML()
{
	ULog.Info("Untold.LoadLooksRDBXML()");
	var xml:XML = new XML();
	xml.ignoreWhite = true;
	xml.onLoad = function( isLoaded:Boolean )
	{
	  if (isLoaded) {
		ULog.Info("Untold.LoadLooksRDBXML(): LooksRDB.xml Loaded");
		m_LooksRDBXML = xml;
	  } else {
		ULog.Info("Untold.LoadLooksRDBXML(): LooksRDB.xml Loading Error");
		_root.fifo.SlotShowFIFOMessage("LooksRDB.xml Loading Error");
	  }
	}
	xml.load( "Untold/LooksRDB.xml" );
	return;
}*/