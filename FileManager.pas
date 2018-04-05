unit FileManager;
interface
{---------------------------------------------}
function abrirArquivo(nomeArquivo : string) : boolean;
function lerDados(var dados : string) : boolean;
procedure fecharArquivo();
{---------------------------------------------}
implementation

var
   arquivo: text;
   caminho: string;

function abrirArquivo(nomeArquivo : string) : boolean;
begin
     caminho := nomeArquivo;
     assign(arquivo, nomeArquivo);
     {$i-}
     reset(arquivo);
     {$i+}
     if (IORESULT = 0) then
        abrirArquivo := true
     else
         abrirArquivo := false;
end;

function lerDados(var dados : string) : boolean;
begin
     if eoln(arquivo) then
     begin
          readln(arquivo,dados);
          if eof(arquivo) then
             exit(false);
     end;
     read(arquivo,dados);
     exit(true);
end;

procedure fecharArquivo();
begin
     close(arquivo);
end;

end.
