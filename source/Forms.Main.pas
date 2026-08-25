unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL,
  VirtualTrees;

type
  PMyData = ^TMyData;
  TMyData = record
    Caption: string;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    VirtualStringTree1: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VirtualStringTree1InitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Spring;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Spring4D
  var Items: Shared<TStringList>;
  Items := TStringList.Create;
  Items.Value.Add('Smart Setup');
  Memo1.Lines.Add('List content: ' + Items.Value[0]);

  // VirtualTreeView
  VirtualStringTree1.NodeDataSize := SizeOf(TMyData);
  VirtualStringTree1.RootNodeCount := 5;
end;

procedure TForm1.VirtualStringTree1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  var Data: PMyData := Sender.GetNodeData(Node);
  if Assigned(Data) then
    CellText := Data.Caption;
end;

procedure TForm1.VirtualStringTree1InitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  var Data: PMyData := Sender.GetNodeData(Node);
  Data.Caption := 'Item ' + IntToStr(Node.Index + 1);
end;

end.
