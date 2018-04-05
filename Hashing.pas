unit Hashing;
interface
{---------------------------------------------}
type
    {Registro usado nas tabelas de palavras reservadas e de operadores}
    lexema = record
          palavra : string[255];
          subclasse : integer;
    end;

    {Lista que usaremos para armazenar a tabela com palavras reservadas}
    lista = ^reg;
    reg = record
        elemento : lexema;
        prox : lista;
    end;

//function hash(palavra : string; tamanhoTabela : integer) : integer;
procedure mostrarLista(inicio: lista);
procedure inserirTabela(item: lexema; var tabela : array of lista; tamanhoTabela : integer);
function consultarTabela(var item: lexema; var tabela : array of lista; tamanhoTabela : integer): boolean;
function consultarTabela(palavra: string[255]; var subclasse: integer; var tabela : array of lista; tamanhoTabela : integer): boolean;

{---------------------------------------------}
implementation

{Função que dada uma string e o tamanho da tabela na qual ela será
inserida ou consultada, retorna a sua posição}
function hash(palavra : string[255]; tamanhoTabela : integer) : integer;
var
   n, i, fim, peso: integer;
begin
     //Verificando se a palavra tem pelo menos 5 caracteres
     n := ord(palavra[0]);
     if (n > 5) then
        n := 5;

     hash := 0;
     peso := 5;

     {if (n < 5) then             //vamos pegar apenas as 5 primeiras letras de cada palavra
        fim := n                 // a não ser q a palavra tenha menos de 5 letras, ai pegamos todas
     else
        fim := 5; }

     for i := 1 to n do
     begin
            hash := hash + peso*ord(lowercase(palavra[i]));  //somamos o valor da tabela ASCII dos primeiros
            peso := peso - 1;                                //caracteres da palavra (levando todos para minúsculos
     end;                                                    //pois o Pascal não é case sensitive)


     hash := hash mod tamanhoTabela;             //retornamos (hash % tamanhotabela)
end;

{Insere uma string em uma lista de strings}
procedure inserirLista(var inicio: lista; item: lexema);
var
   novo: lista;
begin
     new(novo);                      //instância novo registro
     novo^.elemento := item;
     novo^.prox := inicio;           //insere o elemento no início da lista

     inicio := novo;
end;

{Verifica se a string palavra se encontra na lista}
function consultarLista(inicio: lista; item : lexema; var subclasse : integer) : boolean;
var
   p : lista;
begin
     if inicio = nil then       //se a lista está vazia não tem onde procurar
        exit(false)
     else
     begin
         p := inicio;
         repeat                                                  //percorremos a lista
               if (lowercase(p^.elemento.palavra) = lowercase(item.palavra)) then      //se encontrarmos a palavra buscada
               begin
                  subclasse := p^.elemento.subclasse;
                  exit(true);                                   //retornarmos true
               end;
               p := p^.prox;
         until p = nil;                          //fazemos isso até que a lista acabe
     end;
     exit(false);
end;

{Apenas para verificar se as palavras estão devidamente armazenadas, dificilmente utilizaremos isso de fato}
procedure mostrarLista(inicio: lista);
var
   p : lista;
begin
     if inicio = nil then
        exit
     else
     begin
         p := inicio;
         repeat
               write('(',p^.elemento.palavra,',',p^.elemento.subclasse,') ');
               p := p^.prox;
         until p = nil;
     end;

end;

procedure inserirTabela(item: lexema; var tabela : array of lista; tamanhoTabela : integer);
var
   pos : integer;
begin
     pos := hash(item.palavra, tamanhoTabela);
     inserirLista(tabela[pos],item);
end;

function consultarTabela(var item: lexema; var tabela : array of lista; tamanhoTabela : integer): boolean;
var
   pos : integer;
begin
     pos := hash(item.palavra, tamanhoTabela);
     consultarTabela := consultarLista(tabela[pos],item, item.subclasse);
end;

function consultarTabela(palavra: string[255]; var subclasse: integer; var tabela : array of lista; tamanhoTabela : integer): boolean;
var
   pos : integer;
   item : lexema;
begin
     subclasse := -1;
     item.palavra := palavra;
     pos := hash(palavra, tamanhoTabela);
     consultarTabela := consultarLista(tabela[pos],item, subclasse);
end;

end.
