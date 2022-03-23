{
  Export spell tomes data needed for Better Spell Learning patching into a csv file (comma separated, values in double quotes ["]).
  The data can be cleaned and updated in the spreadsheet for later import.
  Import script coming later.

  Script based on "Skyrim - Export and import weapons stats from spreadsheet file".
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
            slBooks.Add('"EDID","difficulty","LearnSpell","School","SpellLearned","ThisBook","DESC","Learned Spell Flag","Type Flag","Skill Flag","CNAM"');
               
        end;

    function Process(e: IInterface): integer;

        var
            i, ec: integer;
            SpellRecord, SpellEffects, EffectRecord: IInterface;
            dnam, difficulty, school : string;

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
                dnam := GetElementEditValues(EffectRecord, 'dnam');
                difficulty := GetElementEditValues(EffectRecord, 'Magic Effect Data\DATA\Minimum Skill Level');
                school := GetElementEditValues(EffectRecord, 'Magic Effect Data\DATA\Magic Skill');
                i := i + 1;
            until (dnam <> '') or (i = ec);

            // Add the record to list
            // use square brackets [] on formid to prevent Excel from treating them as a numbers
            slBooks.Add(Format('"%s","%s","%s","%s","[%s]","[%s]","%s","%s","%s","%s","%s"', [
                GetElementEditValues(e, 'EDID'),
                difficulty,
                GetElementEditValues(SpellRecord, 'FULL - Name'),
                UpperCase(school),
                IntToHex(GetElementNativeValues(e, 'DATA\Spell'), 8),
                // FixedFormID depends only on explicit masters and not affected by plugin's load order
                IntToHex(FixedFormID(e), 8), 
                GetElementEditValues(e, 'DESC'),
                GetElementEditValues(e, 'DATA\Flags\Teaches Spell'),
                GetElementEditValues(e, 'DATA\Type'),
                GetElementEditValues(e, 'DATA\Skill'),
                dnam
            ]));
            
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
    
        slBooks.Free;
    
        end;

end.
