procedure InitializeWizard;
begin
  InitializeGUI;
end;

procedure CurStepChanged(const CurStep: TSetupStep);
begin

  // Run preparing steps before install of files
  if CurStep = ssInstall then
  begin
    if UsingWinNT then
    begin
      UnInstallOldVersion();

      Log(Format('Selected Tasks - Path: %d, Associate: %d', [PathChkBox.State, PathExtChkBox.State]));

      if IsModifyPath then
        ModifyPath([ExpandConstant('{app}') + '\bin']);

      if IsAssociated then
        ModifyFileExts(['.rb', '.rbw']);

#ifdef HaveUtf8ChkBox
      if IsUtf8 then
        ModifyRubyopt(['-Eutf-8']);
#endif

      if IsComponentSelected('msys2') then
        DeleteRubyMsys2Directory();

    end else
      MsgBox('Looks like you''ve got on older, unsupported Windows version.' #13 +
             'Proceeding with a reduced feature set installation.',
             mbInformation, MB_OK);
  end;

  // Final steps before installer closes
  if CurStep = ssDone then
  begin
    Log(Format('Selected Tasks - DevkitInstall %d', [DevkitChkBox.State]));
    if IsDevkitInstall then
      RunDevkitInstall();
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectDir then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);

  {* Disable MSYS2 component install, when it is already present in the install directory,
     but take component selection as set per /COMPONENTS param when in slient install. *}
  if (CurPageID = wpSelectComponents) and (not WizardSilent) then
  begin
    EnableMsys2Component(Msys2AlreadyInstalled() = '');
    ComplistClickCheck(TObject.Create);
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  {* store install choices so we can use during uninstall *}
  if IsModifyPath then
    SetPreviousData(PreviousDataKey, 'PathModified', 'yes');
  if IsAssociated then
    SetPreviousData(PreviousDataKey, 'FilesAssociated', 'yes');

#ifdef HaveUtf8ChkBox
  if IsUtf8 then
    SetPreviousData(PreviousDataKey, 'Utf8', 'yes');
#endif
end;

procedure CurUninstallStepChanged(const CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if UsingWinNT then
    begin
      if GetPreviousData('PathModified', 'no') = 'yes' then
        ModifyPath([ExpandConstant('{app}') + '\bin']);

      if GetPreviousData('FilesAssociated', 'no') = 'yes' then
        ModifyFileExts(['.rb', '.rbw']);

#ifdef HaveUtf8ChkBox
      if GetPreviousData('Utf8', 'no') = 'yes' then
        ModifyRubyopt(['-Eutf-8']);
#endif

    end;
  end;
end;
