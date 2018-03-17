// RubyInstaller Inno Setup GUI Customizations
//
// Copyright (c) 2009-2012 Jon Maken
// Copyright (c) 2012 Yusuke Endoh
// Revision: 2012-05-28 13:58:04 -0600
// License: Modified BSD License

const
  ChkBoxBaseY = 95;
  ChkBoxBaseHeight = 17;
  ChkBoxBaseLeft = 18;

var
  PathChkBox, PathExtChkBox, Utf8ChkBox, DevkitChkBox: TCheckBox;
  CompLabel: TLabel;
  ComplistPrevClickCheck: TNotifyEvent;

function IsAssociated(): Boolean;
begin
  Result := PathExtChkBox.Checked;
end;

function IsModifyPath(): Boolean;
begin
  Result := PathChkBox.Checked;
end;

function IsDevkitInstall(): Boolean;
begin
  Result := DevkitChkBox.Checked;
end;

function IsUtf8(): Boolean;
begin
  Result := Utf8ChkBox.Checked;
end;


procedure ParseSilentTasks();
var
  I, N: Integer;
  Param: String;
  Tasks: TStringList;
begin
  {* parse command line args for silent install tasks *}
  for I := 0 to ParamCount do
  begin
    Param := AnsiUppercase(ParamStr(I));
    if Pos('/TASKS', Param) <> 0 then
    begin
      Param := Trim(Copy(Param, Pos('=', Param) + 1, Length(Param)));
      try
        // TODO check for too many tasks to prevent overflow??
        Tasks := StrToList(Param, ',');
        for N := 0 to Tasks.Count - 1 do
          case Trim(Tasks.Strings[N]) of
            'MODPATH': PathChkBox.State := cbChecked;
            'NOMODPATH': PathChkBox.State := cbUnchecked;
            'ASSOCFILES': PathExtChkBox.State := cbChecked;
            'NOASSOCFILES': PathExtChkBox.State := cbUnchecked;
            'RIDKINSTALL': DevkitChkBox.State := cbChecked;
            'NORIDKINSTALL': DevkitChkBox.State := cbUnchecked;
            'DEFAULTUTF8': Utf8ChkBox.State := cbChecked;
            'NODEFAULTUTF8': Utf8ChkBox.State := cbUnchecked;
          end;
      finally
        Tasks.Free;
      end;
    end;
  end;
end;

procedure URLText_OnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  if Sender is TNewStaticText then
    ShellExec('open', TNewStaticText(Sender).Caption, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure RunDevkitInstall();
var
  ErrorCode: Integer;
  ridkpath: String;
begin
  ridkpath := ExpandConstant('{app}') + '\bin\ridk.cmd';
  ShellExec('open', ridkpath, 'install', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure ComplistClickCheck(Sender: TObject);
begin
  if Msys2AlreadyInstalled() then
    if (WizardForm.ComponentsList.Items.Count > 1) and WizardForm.ComponentsList.Checked[1] then
      CompLabel.Caption := 'ATTENTION: MSYS2 is already present in the Ruby install directory. It will be deleted now and then reinstalled. Additional installed pacman packages will be removed.'
    else
      CompLabel.Caption := 'MSYS2 is already present in the Ruby install directory and will not be deleted. However it can be updated per `ridk install` on the last page of the installer.'
  else
    CompLabel.Caption := '';

  ComplistPrevClickCheck(Sender);
end;

procedure EnableMsys2Component(enable: Boolean);
begin
  if WizardForm.ComponentsList.Items.Count > 1 then
    WizardForm.ComponentsList.Checked[1] := enable;
end;

procedure InitializeGUI;
var
  ChkBoxCurrentY: Integer;
  Page: TWizardPage;
  HostPage: TNewNotebookPage;
  URLText, TmpLabel: TNewStaticText;
begin

  {* Add label to components list *}

  CompLabel := TLabel.Create(WizardForm);
  CompLabel.Parent := WizardForm.SelectComponentsPage;
  CompLabel.Left := WizardForm.ComponentsList.Left;
  CompLabel.Width := WizardForm.ComponentsList.Width;
  CompLabel.Height := ScaleY(40);
  CompLabel.Top :=
    WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompLabel.Height;
  CompLabel.AutoSize := False;
  CompLabel.WordWrap := True;

  WizardForm.ComponentsList.Height :=
    WizardForm.ComponentsList.Height - CompLabel.Height - ScaleY(8);

  {* Bypass click event on ComponentsList *}
  ComplistPrevClickCheck := WizardForm.ComponentsList.OnClickCheck;
  WizardForm.ComponentsList.OnClickCheck := @ComplistClickCheck;

  {* Path, and file association task check boxes *}

  Page := PageFromID(wpSelectDir);
  ChkBoxCurrentY := ChkBoxBaseY;

  PathChkBox := TCheckBox.Create(Page);
  PathChkBox.Parent := Page.Surface;
  PathChkBox.State := cbChecked;
  PathChkBox.Caption := CustomMessage('AddPath');
  PathChkBox.Hint := CustomMessage('AddPathHint');
  PathChkBox.ShowHint := True;
  PathChkBox.Alignment := taRightJustify;
  PathChkBox.Top := ScaleY(ChkBoxCurrentY);
  PathChkBox.Left := ScaleX(ChkBoxBaseLeft);
  PathChkBox.Width := Page.SurfaceWidth;
  PathChkBox.Height := ScaleY(ChkBoxBaseHeight);
  ChkBoxCurrentY := ChkBoxCurrentY + ChkBoxBaseHeight;

  PathExtChkBox := TCheckBox.Create(Page);
  PathExtChkBox.Parent := Page.Surface;
  PathExtChkBox.State := cbChecked;
  PathExtChkBox.Caption := CustomMessage('AssociateExt');
  PathExtChkBox.Hint := CustomMessage('AssociateExtHint');
  PathExtChkBox.ShowHint := True;
  PathExtChkBox.Alignment := taRightJustify;
  PathExtChkBox.Top := ScaleY(ChkBoxCurrentY);
  PathExtChkBox.Left := ScaleX(ChkBoxBaseLeft);
  PathExtChkBox.Width := Page.SurfaceWidth;
  PathExtChkBox.Height := ScaleY(ChkBoxBaseHeight);
  ChkBoxCurrentY := ChkBoxCurrentY + ChkBoxBaseHeight;

  Utf8ChkBox := TCheckBox.Create(Page);
  Utf8ChkBox.Parent := Page.Surface;
  Utf8ChkBox.State := cbUnchecked;
  Utf8ChkBox.Caption := CustomMessage('DefaultUtf8');
  Utf8ChkBox.Hint := CustomMessage('DefaultUtf8Hint');
  Utf8ChkBox.ShowHint := True;
  Utf8ChkBox.Alignment := taRightJustify;
  Utf8ChkBox.Top := ScaleY(ChkBoxCurrentY);
  Utf8ChkBox.Left := ScaleX(ChkBoxBaseLeft);
  Utf8ChkBox.Width := Page.SurfaceWidth;
  Utf8ChkBox.Height := ScaleY(ChkBoxBaseHeight);

  {* Single Ruby installation tip message *}

  TmpLabel := TNewStaticText.Create(Page);
  TmpLabel.Parent := Page.Surface;
  TmpLabel.Top := ScaleY(ChkBoxCurrentY + 30);
  TmpLabel.Left := ScaleX(6);
  TmpLabel.Width := Page.SurfaceWidth;
  TmpLabel.WordWrap := True;
  TmpLabel.Caption := CustomMessage('MouseoverHint');

  {* Labels and links back to RubyInstaller project pages *}

  HostPage := WizardForm.FinishedPage;

  DevkitChkBox := TCheckBox.Create(HostPage);
  DevkitChkBox.Parent := HostPage;
  if WizardSilent then DevkitChkBox.State := cbUnchecked
  else DevkitChkBox.State := cbChecked;
  DevkitChkBox.Caption := CustomMessage('DevkitInstall');
  DevkitChkBox.Hint := CustomMessage('DevkitInstallHint');
  DevkitChkBox.ShowHint := True;
  DevkitChkBox.Alignment := taRightJustify;
  DevkitChkBox.Top := ScaleY(160);
  DevkitChkBox.Left := ScaleX(176);
  DevkitChkBox.Width := HostPage.Width;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := DevkitChkBox.Top + 20;
  TmpLabel.Left := DevkitChkBox.Left + 17;
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := CustomMessage('DevkitInstall2');

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(240);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := CustomMessage('WebSiteLabel');

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://rubyinstaller.org';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(256);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := CustomMessage('SupportGroupLabel');

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://groups.google.com/group/rubyinstaller';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(272);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := CustomMessage('WikiLabel');

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'https://wiki.github.com/larskanis/rubyinstaller2';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  ParseSilentTasks;
end;
