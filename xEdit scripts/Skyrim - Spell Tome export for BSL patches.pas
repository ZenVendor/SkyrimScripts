{
  Export spell tomes data needed for Better Spell Learning patching into a csv file (comma separated, values in double quotes ["]).
  For use with the import script.
  
  0. Copy the .pas files into your xEdit/Edit Scripts folder.
  1. Select the spell tomes you want to patch in the original mod (you can select all books, the script will only export Spell Tomes)
        Right-click, Apply script and select this script.
  2. Open the exported .csv file and clean up the CNAM descriptions and save.
  3. Open the file in a text editor to make sure that all fields containing spaces are in double quotes and that quotes within text are escaped (" => ""). 
  4. Select the tomes in the mod (this time just the tomes), right-click and Copy as override into a new .esp file.
  5. Right-click the new mod and Add masters - Add Skyrim, Update, Dragonborn, Dawnguard and Better Spell Learning.
  6. Right-click the new mod and Sort masters.
  7. Copy form ID from one of Better Spell Learning tomes.
  8. Select the tomes in the new mod, right-click, Apply script and select Skyrim - Copy VMAD subrecord. Paste the copied FormID. 
        If you get an error, check the original mod's dependencies and add the missing masters. Sort after adding.
  9. With the tomes selected, right-click, Apply script and select the import script. Select the prepared file.
  10. Right-click the new mod and Clean masters
  11. Save.
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
            slBooks.Add('"FormID","difficulty","LearnSpell","School","SpellLearned","ThisBook","CNAM"');
               
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
                i := i + 1;
            until (dnam <> '') or (i >= ec);
                
            // Create the record
            slValues := TStringList.Create();

            // FixedFormID depends only on explicit masters and not affected by plugin's load order
            slValues.Add('[' + IntToHex(FixedFormID(e), 8) + ']');
            slValues.Add(difficulty);
            slValues.Add(GetElementEditValues(SpellRecord, 'FULL - Name'));
            slValues.Add(UpperCase(school));
            slValues.Add('[' + IntToHex(FixedFormID(SpellRecord), 8) + ']');
            // Second time just to keep the order
            slValues.Add('[' + IntToHex(FixedFormID(e), 8) + ']');
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
