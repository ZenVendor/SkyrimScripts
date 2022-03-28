# SkyrimScripts
Scripts for Skyrim mods and tools


## xEdit Scripts
Scripts for xEdit/TES5edit to speed up creating patches for Better Spell Learning mod.

- Skyrim - Spell Tome export for BSL patches manual
- Skyrim - Spell Tome export for BSL patches
- Skyrim - Spell Tome import for BSL patches

---

### How to use
0. Copy the scripts to [Edit scripts] in your xEdit folder
#### Export
1. Select Spell Tomes from the original mod you want to patch (you can select all books, the script exports only the Spell Tomes)
2. Right-click, Apply script and select the export script:
	- [Skyrim - Spell Tome export for BSL patches manual]
*This is for manual updates. Includes all relevant fields*
	-	[Skyrim - Spell Tome export for BSL patches]
	*This is for use with the import script*
  3. Open the exported .csv file and clean up the CNAM descriptions. They usually need some editing and getting rid of values in <>. The book  will not populate these variables.
  4. Save and open the file in a text editor to make sure that all fields containing spaces are in double quotes and that quotes within text are escaped (" => ""). 
  #### Patch preparation
  5. Select the tomes in the original mod (this time just the tomes), right-click and [Copy as override] into a new .esp file. Give it a name and save.
  6. Right-click the new mod and [Add masters] - select *Skyrim*, *Update*, *Dragonborn*, *Dawnguard* and *Better Spell Learning*.
  7. Right-click the new mod and [Sort masters].
  8. Copy a form ID from one of *Better Spell Learning* tomes.
  9. Select the tomes in the new mod, right-click and [Apply script]. 
Select [Skyrim - Copy VMAD subrecord]. Use the copied FormID. 
*If you get an error, check the original mod's dependencies and add the missing masters. Sort after adding.*
#### Import
  10. Select the tomes in the new mod, right-click and [Apply script]
Select the import script: [Skyrim - Spell Tome import for BSL patches] and open the prepared .csv
  11. Right-click the new mod and [Clean masters]
  12. Save.
