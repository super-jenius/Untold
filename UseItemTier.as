// Use Item Tier
// Completes when specified item is used
import com.Utils.ID32;
import com.GameInterface.Game.Character;
import GUI.Inventory.IconBox;
import com.Components.ItemSlot;
import com.Utils.DragObject;

class UseItemTier extends BaseTier
{
	public var m_ItemName:String;
	public var m_SelectedItemName:String;

	public function LoadXML(tierNode:XMLNode)
	{
		//ULog.Info("UseItemTier.LoadXML()");
		this.SetItem(tierNode.attributes.itemName);
	}

	public function SetItem(itemName:String)
	{
		//ULog.Info("UseItemTier.SetItem(): itemName=" + itemName);
		m_ItemName = itemName;
	}
	
	private function CheckItem(itemPos:Number)
	{
		m_SelectedItemName = _root.backpack2.m_Inventory.m_Items[itemPos].m_Name;
		if (m_ItemName.toLowerCase().indexOf(m_SelectedItemName.toLowerCase()) >= 0) {
			// Item added. End Tier.
			ULog.Info("UseItemTier.CheckItem(): Item used");
			this.EndTier();
		}
	}
	
	public function StartTier()
	{
		ULog.Info("UseItemTier.StartTier(): m_ItemName=" + m_ItemName);
		for (var i=0; i < _root.backpack2.m_IconBoxes.length; i++) {
			_root.backpack2.m_IconBoxes[i].SignalMouseDownItem.Connect(SlotMouseDownItem, this);
			_root.backpack2.m_IconBoxes[i].SignalMouseUpItem.Connect(SlotMouseUpItem, this);
		}
	}
	
	// No UseItem signal, so adapted mouse clicks from Backpack2.as
	function SlotMouseDownItem(iconBox:IconBox, itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
	{
		if (Key.isDown(Key.CONTROL) && buttonIndex == 1)
		{
			// do nothing
		}
		else if (clickCount == 2 && buttonIndex == 1 && !itemSlot.IsLocked())
		{
				this.CheckItem(itemSlot.GetSlotID());
		}
	}

	function SlotMouseUpItem(iconBox:IconBox, itemSlot:ItemSlot, buttonIndex:Number)
	{
		if (!Key.isDown(Key.CONTROL) && buttonIndex == 1)
		{
			// do nothing
		}
		else if (buttonIndex == 2)
		{
			var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
			if (currentDragObject != undefined && currentDragObject.type == "item")
			{
				// do nothing
			}
			else
			{
				if(!Key.isDown(Key.CONTROL) && !itemSlot.IsLocked())
				{
					this.CheckItem(itemSlot.GetSlotID());
				}
			}
		}
	}

	public function ConvertToXML()
	{
		var tierXML:String = super.ConvertToXML(true);
		tierXML += 'itemName="' + m_ItemName + '" '
			+ '/>\n'
		return tierXML;
	}

}