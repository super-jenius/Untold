// Untold Stories logging function
// Logs message to ClientLog.txt
// Optionally logs info messages. Always logs errors.
import com.GameInterface.Log;

class ULog 
{
	public static var m_LogInfo:Boolean;   
	
	public static function Info(message:String)
	{
		if (m_LogInfo == true) {
			// Must be logged as WARNING, because lower level messages don't appear in ClientLog.txt
			Log.Warning("UntoldStories", message);
		}
	}
	
	public static function Error(message:String)
	{
		Log.Error("UntoldStories", message);
	}
}