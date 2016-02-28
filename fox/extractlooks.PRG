* Extract RDB ID and descriptions from files
* Visual FoxPro program
Local lcRDBFolder, lnFiles, lnFile, lcFile, lcContents, lnRDBID, lcFullDesc, lcDesc
Local Array laRDBFiles[1]

Wait "Extracting Looks RDB Info..." WINDOW nowait

Close Database All 
Use LooksRDB

lcRDBFolder = "E:\tswrdb\tswrdb-cmdui\exported\1010226 (Looks Package)\"
lnFiles = ADir(laRDBFiles, Addbs(lcRDBFolder) + "*.*" )

For lnFile = 1 to lnFiles
	lcFile = Addbs(lcRDBFolder) + laRDBFiles[lnFile, 1]
	lnRDBID = Val(JustFname(laRDBFiles[lnFile, 1]))
	lcContents = FileToStr(lcFile)
	lcFullDesc = Substr(StrExtract(lcContents, "", Chr(26)), 3)
	lcDesc = StrExtract(lcFullDesc, "", Chr(18),1,2)
	If !Seek(lnRDBID, "LooksRDB", "RDBID")
		Append Blank
	EndIf 
	Replace RDBID with lnRDBID, Desc with lcDesc, FullDesc with lcFullDesc in LooksRDB
*	? lnRDBID, lcDesc
EndFor 

Select RDBID, Desc from LooksRDB ;
	where !Empty(Desc) ;
	order by Desc ;
	into cursor Looks
	
CursorToXML("Looks", "LooksRDB.xml", 2, 512)

Close Databases all
Wait clear
MessageBox("Extraction Complete.")