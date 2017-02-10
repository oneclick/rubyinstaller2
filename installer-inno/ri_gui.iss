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
  PathChkBox, PathExtChkBox, DevkitChkBox: TCheckBox;

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
            'ASSOCFILES': PathExtChkBox.State := cbChecked;
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

procedure InitializeWizard;
var
  ChkBoxCurrentY: Integer;
  Page: TWizardPage;
  HostPage: TNewNotebookPage;
  URLText, TmpLabel: TNewStaticText;
begin

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

  {* Single Ruby installation tip message *}

  TmpLabel := TNewStaticText.Create(Page);
  TmpLabel.Parent := Page.Surface;
  TmpLabel.Top := ScaleY(ChkBoxCurrentY + 30);
  TmpLabel.Left := ScaleX(6);
  TmpLabel.Width := Page.SurfaceWidth;
  TmpLabel.WordWrap := True;
  TmpLabel.Caption := CustomMessage('MouseoverHint');

  ParseSilentTasks;


  {* Labels and links back to RubyInstaller project pages *}

  HostPage := WizardForm.FinishedPage;

  DevkitChkBox := TCheckBox.Create(HostPage);
  DevkitChkBox.Parent := HostPage;
  DevkitChkBox.State := cbChecked;
  DevkitChkBox.Caption := CustomMessage('DevkitInstall');
  DevkitChkBox.Hint := CustomMessage('DevkitInstallHint');
  DevkitChkBox.ShowHint := True;
  DevkitChkBox.Alignment := taRightJustify;
  DevkitChkBox.Top := ScaleY(160);
  DevkitChkBox.Left := ScaleX(176);
  DevkitChkBox.Width := HostPage.Width;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := DevkitChkBox.Top + DevkitChkBox.Height;
  TmpLabel.Left := DevkitChkBox.Left;
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := CustomMessage('DevkitInstall2');

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(220);
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
  TmpLabel.Top := ScaleY(236);
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
  TmpLabel.Top := ScaleY(252);
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
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectDir then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
end;
