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
