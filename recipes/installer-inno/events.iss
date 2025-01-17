procedure InitializeWizard;
begin
  InitializeGUI;
end;

procedure CurStepChanged(const CurStep: TSetupStep);
begin

  // Run preparing steps before install of files
  if CurStep = ssInstall then
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

    if WizardIsComponentSelected('msys2') then
      DeleteRubyMsys2Directory();
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
    if GetPreviousData('PathModified', 'no') = 'yes' then
      ModifyPath([ExpandConstant('{app}') + '\bin']);

    if GetPreviousData('FilesAssociated', 'no') = 'yes' then
      ModifyFileExts(['.rb', '.rbw']);

#ifdef HaveUtf8ChkBox
    if GetPreviousData('Utf8', 'no') = 'yes' then
      ModifyRubyopt(['-Eutf-8']);
#endif

    {* Remove SSL junction link *}
    DelTree(ExpandConstant('{app}/ssl'), True, False, False);

    if ExpandConstant('{param:allfiles|yes}') = 'yes' then
    begin
      {* Remove possible MSYS2 *}
      DelTree(ExpandConstant('{app}/msys32'), True, True, True);
      DelTree(ExpandConstant('{app}/msys64'), True, True, True);
      {* Remove binstubs of installed gems *}
      DelTree(ExpandConstant('{app}/bin/*'), False, True, False);
      {* Remove installed gems *}
      DelTree(ExpandConstant('{app}/lib/ruby/gems'), True, True, True);
      {* Remove config of "ridk use" *}
      DelTree(ExpandConstant('{app}/ridk_use/rubies.yml'), False, True, False);
    end;
  end;
end;
