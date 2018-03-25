procedure InitializeWizard;
begin
  InitializeGUI;
end;

procedure CurStepChanged(const CurStep: TSetupStep);
begin

  // TODO move into ssPostInstall just after install completes?
  if CurStep = ssInstall then
  begin
    if UsingWinNT then
    begin
      Log(Format('Selected Tasks - Path: %d, Associate: %d', [PathChkBox.State, PathExtChkBox.State]));

      if IsModifyPath then
        ModifyPath([ExpandConstant('{app}') + '\bin']);

      if IsAssociated then
        ModifyFileExts(['.rb', '.rbw']);

      if IsUtf8 then
        ModifyRubyopt(['-Eutf-8']);

      UnInstallOldVersion();

      if IsComponentSelected('msys2') then
        DeleteRubyMsys2Directory();

    end else
      MsgBox('Looks like you''ve got on older, unsupported Windows version.' #13 +
             'Proceeding with a reduced feature set installation.',
             mbInformation, MB_OK);
  end;

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
  if IsUtf8 then
    SetPreviousData(PreviousDataKey, 'Utf8', 'yes');

  SetPreviousData(PreviousDataKey, 'RubyInstallerId', ExpandConstant('{#PackageBaseId}\{#RubyVersion}'));
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

      if GetPreviousData('Utf8', 'no') = 'yes' then
        ModifyRubyopt(['-Eutf-8']);
    end;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin

  {* Skip components page if RubyInstaller without MSYS2 is running and no previous Ruby MSYS2 directory is present. *}
  if (PageID = wpSelectComponents) and
      (WizardForm.ComponentsList.Items.Count > 1) and
      (not WizardForm.ComponentsList.ItemEnabled[1]) and
      (Msys2AlreadyInstalled() = '') then
    Result := True
  else
    {* In all other cases present the components page, to show what is getting installed. *}
    Result := False;
end;
