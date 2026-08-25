unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
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
var
  Items: Shared<TStringList>;
begin
  Items := TStringList.Create;
  Items.Value.Add('Smart Setup');
  Memo1.Lines.Add('List content: ' + Items.Value[0]);
end;

end.
