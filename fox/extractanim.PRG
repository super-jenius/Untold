* Extract RDB ID and descriptions from files
* Visual FoxPro program
Local lcRDBFolder, lnFiles, lnFile, lcFile, lcContents, lnOccurence, lcAnim, lcName, lcDuration, lcLoop
Local Array laRDBFiles[1]

Wait "Extracting Animation Info..." WINDOW nowait

Close Database All 
Use Anim

lcRDBFolder = "E:\tswrdb\tswrdb-cmdui\exported\1010200 (XML - AnimSys)\"
lnFiles = ADir(laRDBFiles, Addbs(lcRDBFolder) + "*.xml" )

For lnFile = 1 to lnFiles
	lcFile = Addbs(lcRDBFolder) + laRDBFiles[lnFile, 1]
	Wait JustFname(lcFile) window nowait 
	lnRDBID = Val(JustFname(laRDBFiles[lnFile, 1]))
	lcContents = FileToStr(lcFile)
	lnOccurence = 1
	Do while .T.
		lcAnim = StrExtract(lcContents, '<animation ', '>', lnOccurence)
		If !Empty(lcAnim)
			lcName = StrExtract(lcAnim, 'name="', '"')
			lcDuration = StrExtract(lcAnim, 'duration="', '"')
			lcLoop = StrExtract(lcAnim, 'loop="', '"')
			If !Seek(Padr(lcName, 240), "Anim", "Name")
				Append Blank
				Replace Name with lcName, ;
					Duration with lcDuration, ;
					Loop with lcLoop, ;
					Filename with JustFname(lcFile)
			EndIf 
			lnOccurence = lnOccurence + 1 
		Else
			Exit 
		EndIf 
	EndDo 
EndFor 

Select Name, Duration, Loop from Anim ;
	order by Name ;
	into cursor Animation
	
CursorToXML("Animation", "Animation.xml", 2, 512)

Close Databases all
Wait clear
MessageBox("Extraction Complete.")