// Mission List Content
// Borrowed pieces from Claims (Delivered Items)
import com.Components.WindowComponentContent;
import com.Components.ListHeader;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.GameInterface.DistributedValue;
import com.GameInterface.AccountManagement;

class MissionList extends WindowComponentContent
{

    private var m_ClaimList:MultiColumnListView;
    private var m_ScrollBar:MovieClip;
    private var m_MissionColumn:Number = 0;
    private var m_StatusColumn:Number = 1;
    private var m_AuthorColumn:Number = 2;
    private var m_MissionWidth:Number = 275;
    private var m_StatusWidth:Number = 75;
    private var m_AuthorWidth:Number = 150;
    private var m_ScrollBarPosition:Number;
	private var m_MissionList:Array;

    private var m_DeleteButton:Button;
    private var m_ClaimButton:Button;
    private var m_ClaimAllButton:Button;
    private var m_SelectedID:Number;
	
	public var m_CurrentMission;
	private var m_StartingMission:Boolean;
	public var m_MissionXML:XML;
	public var m_MissionStatus:MissionStatus;
	public var m_WebMission:Boolean;
	public var m_WebMissionID:String;
	public var m_WebMissionXML:String;

    public function configUI()
    {        
        
		ULog.Info("MissionList.configUI()");
		AccountManagement.GetInstance().SignalLoginStateChanged.Connect(SlotLoginStateChanged, this);
		
		m_ClaimList.SignalSizeChanged.Connect(Layout, this)
        m_ClaimList.SetItemRenderer("ItemRenderer");
        m_ClaimList.SetHeaderSpacing(3);
        m_ClaimList.SetShowBottomLine(true);
        m_ClaimList.SetScrollBar(m_ScrollBar);
        m_ClaimList.SignalItemClicked.Connect(SlotItemSelected, this);
        
        m_ClaimList.AddColumn(m_MissionColumn, "Mission", m_MissionWidth, 0);
        m_ClaimList.AddColumn(m_StatusColumn, "Status", m_StatusWidth, 0);
        m_ClaimList.AddColumn(m_AuthorColumn, "Author", m_AuthorWidth, 0);
        //m_ClaimList.SetRowCount(5);
        m_ClaimList.SetSize(762, 289);
        m_ClaimList.DisableRightClickSelection(false);

		m_DeleteButton.label = "SANDBOX";
		m_DeleteButton.textField.autoSize = "center";
        m_DeleteButton._y -= 2;
		m_DeleteButton.visible = false;
        m_DeleteButton.addEventListener("click", this, "StartSandbox");
		m_ClaimButton.label = "RESET MISSION";
		m_ClaimButton.textField.autoSize = "center";
        m_ClaimButton._y -= 2;
		m_ClaimButton.visible = true;
		m_ClaimButton.disabled = true;
        m_ClaimButton.addEventListener("click", this, "PromptResetMission");
		m_ClaimAllButton.label = "START MISSION";
		m_ClaimAllButton.textField.autoSize = "center";
        m_ClaimAllButton._y -= 2;
		m_ClaimAllButton.disabled = true;
//        m_ClaimAllButton.addEventListener("click", this, "StartMission");
        m_ClaimAllButton.addEventListener("click", this, "LoadMission");

		m_ScrollBar._height = m_ClaimList._height;
		
		m_MissionStatus = new MissionStatus();
		
        //Layout();
        
    }
	
	public function LoadMissions()
	{
		ULog.Info("MissionList.LoadMissions()");
		m_ClaimList.RemoveAllItems();
		
		m_MissionStatus.LoadStatus();
		
		//this.GetMissionList();
		this.GetXMLMissionList();
	}
	
	// Get list of missions from XML and load into array
	private function GetXMLMissionList()
	{
		ULog.Info("MissionList.GetXMLMissionList()");
		var thisList = this;
		var missionListXML = new XML();
		missionListXML.ignoreWhite = true;
		missionListXML.load('Untold/MissionList.xml');
		missionListXML.onLoad = function(success) {
			if (success) {
				ULog.Info("MissionList.GetXMLMissionList(): XML Load Success");
				thisList.m_MissionList = new Array();
				var missionListNode:XMLNode = missionListXML.firstChild;
				for (var i = 0; i < missionListNode.childNodes.length; i++) {
					var missionNode:XMLNode = missionListNode.childNodes[i];
					if (missionNode) {
						// Get mission tier/status
						thisList.m_MissionStatus.GetStatus(missionNode.attributes.id);
						thisList.m_MissionList.push([missionNode.attributes.title, thisList.m_MissionStatus.m_Status, missionNode.attributes.author, missionNode.attributes.file, 
													 missionNode.attributes.id]);
					}
				}
				thisList.UpdateMissionList();
			} 
			else {
				ULog.Error("MissionList.GetXMLMissionList(): XML Load Failure");
			}
		};
	}
	
/*	// Get list of missions (old array)
	private function GetMissionList()
	{
		// Add missions to array
		// Mission name, Author, Script class
		m_MissionList = new Array();
		m_MissionList.push(["Basic Training", "SuperJenius", BasicTraining]);
		m_MissionList.push(["A Personal Matter", "SuperJenius", APersonalMatter]);
		m_MissionList.push(["The Scroll", "SuperJenius", TheScroll]);
		if (m_MissionDebugWindow._visible == true) {
			m_MissionList.push(["Sandbox", "SuperJenius", Sandbox]);
		}
		this.UpdateMissionList();
	}*/
	
	private function UpdateMissionList()
	{
		ULog.Info("MissionList.UpdateMissionList()");
        for (var i:Number = 0; i < m_MissionList.length; i++ )
		{
			var mission = m_MissionList[i];			
			var missionItem:MCLItemDefault = new MCLItemDefault(i);
			
			// Mission Name
			var missionValue:MCLItemValueData = new MCLItemValueData();
			missionValue.m_Text = mission[0];
			missionItem.SetValue(m_MissionColumn, missionValue, MCLItemDefault.LIST_ITEMTYPE_STRING);
			
			// Status
			var statusValue:MCLItemValueData = new MCLItemValueData();
			statusValue.m_Text = mission[1];
			missionItem.SetValue(m_StatusColumn, statusValue, MCLItemDefault.LIST_ITEMTYPE_STRING);
			
			// Author
			var authorValue:MCLItemValueData = new MCLItemValueData();
			authorValue.m_Text = mission[2];	
			missionItem.SetValue(m_AuthorColumn, authorValue, MCLItemDefault.LIST_ITEMTYPE_STRING);
			
			// Add item
			m_ClaimList.AddItem(missionItem);
		}
	}
	
    private function Layout()
    {        
        SignalSizeChanged.Emit();
    }

    //Slot Item Selected
    private function SlotItemSelected(index:Number):Void
    {
        m_SelectedID = m_ClaimList.GetItems()[index].GetId();
        m_ClaimAllButton.disabled = m_ClaimList.GetSelectedIndex() < 0; // enable start button
		var mission = m_MissionList[m_SelectedID];
		m_ClaimButton.disabled = (mission[1] == ""); // enable reset when mission in progress or complete
		//m_MissionDebugWindow.contentTextField.text = m_SelectedID.toString();
    }
	
/*	// For loading ActionScript mission. Use LoadMission instead for XML.
	private function StartMission()
	{

		// If current mission in progress, ask to abort
		m_MissionDebugWindow.contentTextField.text += "StartMission()";
		if (m_CurrentMission != null)
		{
			m_MissionDebugWindow.contentTextField.text += "\nMission in progress.";
			m_StartingMission = true;
			this.PromptAbortMission();
			return;
		}
		
		var mission = m_MissionList[m_SelectedID];
		Selection.setFocus(null);
		_root["untold\\untold"].m_MissionListWindow._visible = false;

		m_CurrentMission = new mission[2]();
		var thisList = this;
		m_CurrentMission.onMissionComplete = function() {
			thisList.ClearMission();
		}
		m_CurrentMission.ScriptMission();
		m_CurrentMission.StartMission(_root["untold\\untold"]._root["untold\\untold"].m_CustomWindow);
	}*/
	
	public function StartSandbox()
	{

		ULog.Info("MissionList.StartSandbox()");
		// If current mission in progress, ask to abort
		if (m_CurrentMission != null)
		{
			ULog.Info("MissionList.StartSandbox(): Mission in progress");
			m_StartingMission = true;
			this.PromptAbortMission();
			return;
		}
		
		//var mission = m_MissionList[m_SelectedID];
		Selection.setFocus(null);
		if (_root["untold\\untold"].m_MissionListWindow == undefined) {
			ULog.Error("MissionList.StartSandbox(): m_MissionListWindow undefined");
		}
		_root["untold\\untold"].m_MissionListWindow._visible = false;

		m_CurrentMission = new Sandbox();
		var thisList = this;
		m_CurrentMission.onMissionComplete = function() {
			thisList.ClearMission();
		}
		m_CurrentMission.ScriptMission();
		m_CurrentMission.StartMission(_root["untold\\untold"].m_CustomWindow);
	}
	
	// Load local mission from XML file
	public function LoadMission()
	{
		ULog.Info("MissionList.LoadMission()");
		m_WebMission = false;
		if (m_CurrentMission != null)
		{
			ULog.Info("MissionList.LoadMission(): Mission in progress");
			m_StartingMission = true;
			this.PromptAbortMission();
			return;
		}
		
		var mission = m_MissionList[m_SelectedID]
		Selection.setFocus(null);
		if (_root["untold\\untold"].m_MissionListWindow == undefined) {
			ULog.Error("MissionList.LoadMission(): m_MissionListWindow undefined");
		}
		_root["untold\\untold"].m_MissionListWindow._visible = false;

		var thisList = this;
		m_CurrentMission = new BaseMission();
		m_CurrentMission.m_MissionID = mission[4];
		m_CurrentMission.m_MissionStatus = m_MissionStatus;
		m_MissionXML = new XML();
		m_MissionXML.ignoreWhite = true;
		m_MissionXML.load('Untold/' + mission[3]);
		m_MissionXML.onLoad = function(success) {
			if (success) {
				ULog.Info("MissionList.LoadMission(): XML Load Success " + mission[3]);
				thisList.m_CurrentMission.LoadXML(thisList.m_MissionXML);
				thisList.m_CurrentMission.onMissionComplete = function() {
					thisList.ClearMission();
				}
				thisList.m_CurrentMission.StartMission(_root["untold\\untold"].m_CustomWindow);
			} 
			else {
				ULog.Error("MissionList.LoadMission(): XML Load Failure " + mission[3]);
			}
		};
	}

	// Load web mission from XML string
	public function LoadWebMission(missionID, missionXML)
	{
		ULog.Info("MissionList.LoadWebMission(): missionID " + missionID);
		m_WebMission = true;
		m_WebMissionID = missionID;
		m_WebMissionXML = missionXML;
		if (m_CurrentMission != null)
		{
			ULog.Info("MissionList.LoadWebMission(): Mission in progress");
			m_StartingMission = true;
			this.PromptAbortMission();
			return;
		}
		
//		var mission = m_MissionList[m_SelectedID]
		Selection.setFocus(null);
//		_root["untold\\untold"].m_MissionListWindow._visible = false;

		var thisList = this;
		m_CurrentMission = new BaseMission();
		m_CurrentMission.m_MissionID = m_WebMissionID;
		m_CurrentMission.m_MissionStatus = m_MissionStatus;
		m_MissionXML = new XML();
		m_MissionXML.ignoreWhite = true;
		m_MissionXML.parseXML(m_WebMissionXML);
		thisList.m_CurrentMission.LoadXML(thisList.m_MissionXML);
		thisList.m_CurrentMission.onMissionComplete = function() {
			thisList.ClearMission();
		}
		thisList.m_CurrentMission.StartMission(_root["untold\\untold"].m_CustomWindow);
	}


	public function PromptAbortMission()
	{
		var dialogIF = new com.GameInterface.DialogIF("Do you want to pause the current mission?", _global.Enums.StandardButtons.e_YesNo, "Message" );
		dialogIF.SignalSelectedAS.Connect( null, SlotAbortReponse, this )
		dialogIF.Go( 4 );   // <-  4 is userdata.
	}

	public function SlotAbortReponse(buttonId, dialogIF:com.GameInterface.DialogIF )
	{
		if (buttonId == 0)	// Yes
		{
			this.ClearMission();
		}
		else // No
		{
			m_StartingMission = false;
		}
	}
	
	public function ClearMission()
	{
		ULog.Info("MissionList.ClearMission()");
		m_CurrentMission.AbortMission();
		m_CurrentMission = null;
		_root["untold\\untold"].ReleaseBackgroundBrowser();
		//m_MissionDebugWindow.contentTextField.text += "\nMission cleared.";
		// If aborting current mission to start new one, call StartMission again
		if (m_StartingMission == true)
		{
			m_StartingMission = false;
			// Use global setTimeout to avoid scoping and re-entry issues
			// _global.setTimeout(this, "StartMission", 1000);
			if (m_WebMission == true) {
				_global.setTimeout(this, "LoadWebMission", 1000, m_WebMissionID, m_WebMissionXML);
			} else {
				_global.setTimeout(this, "LoadMission", 1000);
			}
		}
	}
	
	public function SlotLoginStateChanged( state:Number )
	{

		ULog.Info("MissionList.SlotLoginStateChanged(): State " + state.toString());
		//_global.m_MissionDebugWindow.contentTextField.text = "SlotLoginStateChanged: " + state.toString() + "\n" + _global.m_MissionDebugWindow.contentTextField.text ;
		// If logged off, abort current mission
		if ( state <= _global.Enums.LoginState.e_LoginStateWaitingForGameServerConnection ) {
			ULog.Info("MissionList.SlotLoginStateChanged(): Logged out");
			//_global.m_MissionDebugWindow.contentTextField.text = "Logged out.\n" + _global.m_MissionDebugWindow.contentTextField.text ;
			if (m_CurrentMission <> undefined && m_CurrentMission <> null) {
				this.ClearMission();
			}
		}
	}

	public function PromptResetMission()
	{
		var dialogIF = new com.GameInterface.DialogIF("Do you want to reset your progress on the selected mission?", _global.Enums.StandardButtons.e_YesNo, "Message" );
		dialogIF.SignalSelectedAS.Connect( null, SlotResetReponse, this )
		dialogIF.Go( 4 );   // <-  4 is userdata.
	}

	public function SlotResetReponse(buttonId, dialogIF:com.GameInterface.DialogIF )
	{
		if (buttonId == 0)	// Yes
		{
			this.ResetMission();
		}
		else // No
		{
		}
	}
	
	public function ResetMission()
	{
		ULog.Info("MissionList.ResetMission()");
		var mission = m_MissionList[m_SelectedID];
		m_MissionStatus.SetTier(mission[4], -1);
		this.LoadMissions();
		// If resetting current mission, abort it
		if (m_CurrentMission.m_MissionID == mission[4]) {
			this.ClearMission();
		}
	}

	public function ResetWebMission(missionID)
	{
		ULog.Info("MissionList.ResetWebMission(): missionID " + missionID);
		m_MissionStatus.SetTier(missionID, -1);
		// Mission window will be reloaded by main program
		//this.LoadMissions();
		// If resetting current mission, abort it
		if (m_CurrentMission.m_MissionID == missionID) {
			m_WebMission = true;
			this.ClearMission();
		}
	}

}
