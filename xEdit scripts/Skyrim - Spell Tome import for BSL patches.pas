{
  Import spell tome data needed for Better Spell Learning patching from a csv file (comma separated, values in double quotes ["]).
  For use with export script.
  
}
unit UserScript;

	var
	  slBooks, slValues, slLookup: TStringList;

	function Initialize: integer;
	var
	  i: integer;
	  dlgOpen: TOpenDialog;
	begin
		Result := 0;

		// strings list with weapons data
		slBooks := TStringList.Create;
		// lookup list to find formids when importing
		slLookup := TStringList.Create;
	  
		// Import: select file name to import from
		dlgOpen := TOpenDialog.Create(nil);
		dlgOpen.Filter := 'Spreadsheet files (*.csv)|*.csv';
		if dlgOpen.Execute then begin
			slBooks.LoadFromFile(dlgOpen.FileName);
			// remove the first header line
			if slBooks.Count > 0 then slBooks.Delete(0);
			// create lookup list (just to speed up the import process)
			for i := 0 to slBooks.Count - 1 do
				slLookup.Add(Copy(slBooks[i], 2, 8));
		end;
		dlgOpen.Free;
		
		// nothing to import
		if slBooks.Count = 0 then begin
			slBooks.Free;
			Result := 1;
			Exit;
		end;
	end;

	function Process(e: IInterface): integer;
	var	
		i: integer;
		newDesc: string;
		vmProps: IInterface;
	begin
		Result := 0;

		i := slLookup.IndexOf(IntToHex(FixedFormID(e), 8));
		if i <> -1 then begin
			slValues := TStringList.Create; 
			slValues.CommaText := slBooks[i];
			vmProps := ElementByPath(ElementByIndex(ElementByPath(e, 'VMAD\Scripts'), 0), 'Properties');
			newDesc := '<font face''$HandwrittenFont''><font size=''40''><p align=''center''>' + slValues[2] + '</p></font>[pagebreak]<font size=''20''><p align=''left''>[The tome contains countless diagrams and magical runes. You think if you study them long enough, you may be able to learn how to cast this spell yourself.]</p></font></font>';

			SetElementEditValues(ElementByIndex(vmProps, 6), 'Int32', slValues[1]);
            SetElementEditValues(ElementByIndex(vmProps, 23), 'String', slValues[2]);
            SetElementEditValues(ElementByIndex(vmProps, 36), 'String', slValues[3]);
            SetElementEditValues(ElementByIndex(vmProps, 37), 'Value\Object Union\Object v2\FormID', slValues[4]);
            SetElementEditValues(ElementByIndex(vmProps, 38), 'Value\Object Union\Object v2\FormID', slValues[5]);
            SetElementEditValues(e, 'CNAM', slValues[6]);
			SetElementEditValues(e, 'DESC', newDesc);
            SetElementEditValues(e, 'DATA\Flags\Teaches Spell', 0);
            SetElementEditValues(e, 'DATA\Type', 'Book/Tome');
            SetElementEditValues(e, 'DATA\Skill', 'None');
            
		end;
		slValues.Free;
	end;
	
	function Finalize: integer;
	begin
	  Result := 0;
	  
	  slBooks.Free;
	  slLookup.Free;
	  
	end;

end.