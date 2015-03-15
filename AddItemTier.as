// Add Item Tier
// Completes when specified item is added to inventory
// Currently does not check to see if item is already in inventory
import com.Utils.ID32;
import com.GameInterface.Game.Character;

class AddItemTier extends BaseTier
{
	public var m_ItemName:String;
	public var m_SelectedItemName:String;
	public var m_AutoUseItem:Boolean;
	
	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("AddItemTier.LoadXML()");
		this.SetItem(tierNode.attributes.itemName, (tierNode.attributes.autoUseItem == "true"));
	}

	public function SetItem(itemName:String, autoUseItem:Boolean)
	{
		//ULog.Info("AddItemTier.SetItem(): itemName=" + itemName + " autoUseItem=" + autoUseItem.toString());
		m_ItemName = itemName;
		m_AutoUseItem = autoUseItem;
	}
	
	private function CheckItem(itemPos:Number)
	{
		ULog.Info("AddItemTier.CheckItem()");
		m_SelectedItemName = _root.backpack2.m_Inventory.m_Items[itemPos].m_Name;
		if (m_ItemName.toLowerCase().indexOf(m_SelectedItemName.toLowerCase()) >= 0) {
			ULog.Info("AddItemTier.CheckItem(): Item match");
			if (m_AutoUseItem == true) {
				// Use item immediately
				ULog.Info("AddItemTier.CheckItem(): AutoUse");
				_root.backpack2.m_Inventory.UseItem(itemPos);
			}
			// Item added. End Tier.
			this.EndTier();
		}
	}
	
	public function StartTier()
	{
		ULog.Info("AddItemTier.StartTier(): m_ItemName=" + m_ItemName + " m_AutoUseItem=" + m_AutoUseItem.toString());
		_root.backpack2.m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
	    _root.backpack2.m_Inventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
	}
	
	public function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number)
	{
		this.CheckItem(itemPos);
	}
	
	function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number)
	{  
		// Check if item count changed (stat 26)
		// You can't tell if it went up or down, so assume it went up
		if (stat == 26) {
			this.CheckItem(itemPos);
		}
		// this.MessageBox("Item status changed: " + _root.backpack2.m_Inventory.m_Items[itemPos].m_Name + " stat: " + stat.toString() + " newValue: " + newValue.toString());
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'itemName="' + m_ItemName + '" '
			+ 'autoUseItem="' + m_AutoUseItem.toString() + '" '
			+ '/>\n'
		return tierXML;
	}

}