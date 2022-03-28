{
  Export spell tomes data needed for Better Spell Learning patching into a csv file (comma separated, values in double quotes ["]).
  Meant for overview of original tomes and manual updates. Includes all fields and a EDID for identification of the record.
  Not for use with the import script
}
unit UserScript;

    var
    slBooks: TStringList;
    
    function Initialize: integer;

        var
            dlgOpen: TOpenDialog;
        
        begin
            Result := 0;
            
            slBooks := TStringList.Create;
            slBooks.Add('"FormID","EDID","difficulty","LearnSpell","School","SpellLearned","ThisBook","DESC","Learned Spell Flag","Type Flag","Skill Flag","CNAM"');
               
        end;

    function Process(e: IInterface): integer;

        var
            i, ec: integer;
            SpellRecord, SpellEffects, EffectRecord: IInterface;
            dnam, difficulty, school : string;
            slValues: TStringList;
        begin
            Result := 0;
            
            // process only spell tomes, skip other records
            if Signature(e) <> 'BOOK' then
                Exit;
            if LeftStr(DisplayName(e), 10) <> 'Spell Tome' then
                Exit;

            // Get spell record referenced by the book
            // Both Spell and later Effect select the "winning override".
            // This should assure that the description and minimum level are taken from patches and mods modifying them further in the load order.
            SpellRecord := WinningOverride(RecordByFormID(GetFile(e), GetElementNativeValues(e, 'DATA\Spell'), false));
            
            // Get Spell effects record for DNAM (description - for CNAM of the book), difficulty and school
            SpellEffects := ElementByPath(SpellRecord, 'Effects');

            ec := ElementCount(SpellEffects);
            dnam := '';
            i := 0;

            repeat
                EffectRecord := WinningOverride(RecordByFormID(GetFile(SpellRecord), GetElementNativeValues(ElementByIndex(SpellEffects, i), 'EFID'), false));
                dnam := GetElementEditValues(EffectRecord, 'DNAM');
                difficulty := GetElementEditValues(EffectRecord, 'Magic Effect Data\DATA\Minimum Skill Level');
                school := GetElementEditValues(EffectRecord, 'Magic Effect Data\DATA\Magic Skill');
                AddMessage(IntToStr(i) + ' : ' + school + ' : ' + IntToStr(difficulty) + ' : ' + dnam);
                i := i + 1;
            until (dnam <> '') or (i >= ec);
                
            // Create the record
            slValues := TStringList.Create();

            // FixedFormID depends only on explicit masters and not affected by plugin's load order
            slValues.Add('[' + IntToHex(FixedFormID(e), 8) + ']');
            slValues.Add(GetElementEditValues(e, 'EDID'));
            slValues.Add(difficulty);
            slValues.Add(GetElementEditValues(SpellRecord, 'FULL - Name'));
            slValues.Add(UpperCase(school));
            slValues.Add('[' + IntToHex(FixedFormID(SpellRecord), 8) + ']');
            // Second time just to keep the order
            slValues.Add('[' + IntToHex(FixedFormID(e), 8) + ']');
            slValues.Add(GetElementEditValues(e, 'DESC'));
            slValues.Add('0');
            slValues.Add('Book/Tome');
            slValues.Add('None');
            slValues.Add(dnam);

            // Add the record to list
            slBooks.Add(slValues.CommaText);
            
            //Clean up
            slValues.Free();

        end;


    function Finalize: integer;
        var
            dlgSave: TSaveDialog;

        begin
            Result := 0;
            
            if not Assigned(slBooks) then
                Exit;
                
            // save export file only if we have any data besides header line
            if slBooks.Count > 1 then begin
                // ask for file to export to
                dlgSave := TSaveDialog.Create(nil);
                dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
                dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
                dlgSave.InitialDir := ProgramPath;
                dlgSave.FileName := 'books.csv';
                if dlgSave.Execute then
                    slBooks.SaveToFile(dlgSave.FileName);
                    dlgSave.Free;
                
            end;

        //Clean up
        slBooks.Free;
    
        end;

end.
