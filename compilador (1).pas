program Compilador;
uses crt, Hashing, FileManager;
const
     QTDE_PALAVRAS_RESERVADAS = 63;
     QTDE_OPERADORES = 23;
     QTDE_DELIMITADORES = 13;
     QTDE_TOKENS = 10000;
     
	 //Tipos de tokens
     NUMERO_INTEIRO = 0;
     NUMERO_REAL = 1;
     IDENTIFICADOR = 2;
     PALAVRA_RESERVADA = 3;
     OPERADOR = 4;
     DELIMITADOR = 5;
     _CHAR = 6;
     _STRING = 7;

     //Subclasses de palavra reservada
     //PALAVRA_RESERVADA = 3;
     TIPO = 30;
     FUNCAO = 31;
     //OPERADOR = 4;

     //Subclasses de operador
     ARITMETICO = 40;
     RELACIONAl = 41;
     LOGICO = 42;
     ATRIBUICAO = 43;

     //Erros léxicos
     ERRO_IDENT_MAX = 398;
     ERRO_FIM_INESP = 399; //Fim inesperado
     ERRO_SIMB_DESCONHECIDO = 400; //Símbolo desconhecido
     ERRO_NUM_MAX = 401;
     ERRO_STRING = 402;
     ERRO_NUM = 403; //Estouro do valor do Inteiro
     ERRO_DESCONHECIDO = 404;
	 
type

    {Possíveis tipos de variável}
    TValor = (T_INTEGER,T_REAL,T_CHAR,T_STRING,T_BOOLEAN);

    {Registro/"struct" que representa um token}
    token = record
          classe : integer;
          palavra : string[255];
          subclasse : integer;
          linha : integer;
          coluna : integer;
          {Union para definir o valor de uma variável, se for o caso}
          case tipoValor : TValor of
               T_INTEGER : (valorInt : integer);
               T_REAL : (valorReal : real);
               T_CHAR : (valorChar : char);
               T_STRING : (valorString: string);
               T_BOOLEAN : (valorBool : boolean);
    end;

    {Implementado na unit Hashing
    Registro usado nas tabelas de palavras reservadas e de operadores
    lexema = record
          palavra : string[20];
          subclasse : integer;
    end;
    }
	
var //Variáveis Globais
   tabelaTokens : array[1..QTDE_TOKENS] of token;
   palavrasReservadas : array[1..QTDE_PALAVRAS_RESERVADAS] of lista;
   operadores: array[1..QTDE_OPERADORES] of lista;
   delimitadores: array[1..QTDE_DELIMITADORES] of lista;
   caminho, textoLeitura : string;
   linha, coluna : integer;

{------------------------------------------------------------------------------}

{Cadastra as palavras reservadas da linguagem Pascal}
procedure cadastrarPalavrasReservadas();
var
   i, n: integer;
   palavras : array[1..QTDE_PALAVRAS_RESERVADAS] of lexema;
begin
     for i := 1 to QTDE_PALAVRAS_RESERVADAS do
         palavrasReservadas[i] := nil;

     n := 46;
     palavras[1].palavra := 'and';
     palavras[1].subclasse := OPERADOR;

     palavras[2].palavra := 'array';
     palavras[2].subclasse := PALAVRA_RESERVADA;

     palavras[3].palavra := 'begin';
     palavras[3].subclasse := PALAVRA_RESERVADA;

     palavras[4].palavra := 'case';
     palavras[4].subclasse := PALAVRA_RESERVADA;

     palavras[5].palavra := 'const';
     palavras[5].subclasse := PALAVRA_RESERVADA;

     palavras[6].palavra := 'div';
     palavras[6].subclasse := OPERADOR;

     palavras[7].palavra := 'do';
     palavras[7].subclasse := PALAVRA_RESERVADA;

     palavras[8].palavra := 'downto';
     palavras[8].subclasse := PALAVRA_RESERVADA;

     palavras[9].palavra := 'else';
     palavras[9].subclasse := PALAVRA_RESERVADA;

     palavras[10].palavra := 'end';
     palavras[10].subclasse := PALAVRA_RESERVADA;

     palavras[11].palavra := 'file';
     palavras[11].subclasse := PALAVRA_RESERVADA;

     palavras[12].palavra := 'for';
     palavras[12].subclasse := PALAVRA_RESERVADA;

     palavras[13].palavra := 'function';
     palavras[13].subclasse := PALAVRA_RESERVADA;

     palavras[14].palavra := 'goto';
     palavras[14].subclasse := PALAVRA_RESERVADA;

     palavras[15].palavra := 'if';
     palavras[15].subclasse := PALAVRA_RESERVADA;

     palavras[16].palavra := 'in';
     palavras[16].subclasse := PALAVRA_RESERVADA;

     palavras[17].palavra := 'label';
     palavras[17].subclasse := PALAVRA_RESERVADA;

     palavras[18].palavra := 'mod';
     palavras[18].subclasse := OPERADOR;

     palavras[19].palavra := 'nil';
     palavras[19].subclasse := PALAVRA_RESERVADA;

     palavras[20].palavra := 'not';
     palavras[20].subclasse := OPERADOR;

     palavras[21].palavra := 'of';
     palavras[21].subclasse := PALAVRA_RESERVADA;

     palavras[22].palavra := 'or';
     palavras[22].subclasse := OPERADOR;

     palavras[23].palavra := 'packed';
     palavras[23].subclasse := PALAVRA_RESERVADA;

     palavras[24].palavra := 'procedure';
     palavras[24].subclasse := PALAVRA_RESERVADA;

     palavras[25].palavra := 'program';
     palavras[25].subclasse := PALAVRA_RESERVADA;

     palavras[26].palavra := 'record';
     palavras[26].subclasse := PALAVRA_RESERVADA;

     palavras[27].palavra := 'repeat';
     palavras[27].subclasse := PALAVRA_RESERVADA;

     palavras[28].palavra := 'set';
     palavras[28].subclasse := PALAVRA_RESERVADA;

     palavras[29].palavra := 'then';
     palavras[29].subclasse := PALAVRA_RESERVADA;

     palavras[30].palavra := 'to';
     palavras[30].subclasse := PALAVRA_RESERVADA;

     palavras[31].palavra := 'type';
     palavras[31].subclasse := PALAVRA_RESERVADA;

     palavras[32].palavra := 'until';
     palavras[32].subclasse := PALAVRA_RESERVADA;

     palavras[33].palavra := 'var';
     palavras[33].subclasse := PALAVRA_RESERVADA;

     palavras[34].palavra := 'while';
     palavras[34].subclasse := PALAVRA_RESERVADA;

     palavras[35].palavra := 'with';
     palavras[35].subclasse := PALAVRA_RESERVADA;

     palavras[36].palavra := 'string';
     palavras[36].subclasse := TIPO;

     palavras[37].palavra := 'integer';
     palavras[37].subclasse := TIPO;

     palavras[38].palavra := 'real';
     palavras[38].subclasse := TIPO;

     palavras[39].palavra := 'char';
     palavras[39].subclasse := TIPO;

     palavras[40].palavra := 'boolean';
     palavras[40].subclasse := TIPO;

     palavras[41].palavra := 'writeln';
     palavras[41].subclasse := FUNCAO;

     palavras[42].palavra := 'write';
     palavras[42].subclasse := FUNCAO;

     palavras[43].palavra := 'readln';
     palavras[43].subclasse := FUNCAO;

     palavras[44].palavra := 'readkey';
     palavras[44].subclasse := FUNCAO;

     palavras[45].palavra := 'true';
     palavras[45].subclasse := PALAVRA_RESERVADA;

     palavras[46].palavra := 'false';
     palavras[46].subclasse := PALAVRA_RESERVADA;

     for i := 1 to n do
     begin
         inserirTabela(palavras[i],palavrasReservadas, QTDE_PALAVRAS_RESERVADAS);
     end;
end;

procedure cadastrarOperadores();
var
   i, n: integer;
   palavras : array[1..QTDE_OPERADORES] of lexema;
begin
     for i := 1 to QTDE_OPERADORES do
         operadores[i] := nil;

     n := 16;
     palavras[1].palavra := '+';
     palavras[1].subclasse := ARITMETICO;

     palavras[2].palavra := '-';
     palavras[2].subclasse := ARITMETICO;

     palavras[3].palavra := '*';
     palavras[3].subclasse := ARITMETICO;

     palavras[4].palavra := '/';
     palavras[4].subclasse := ARITMETICO;

     palavras[5].palavra := 'div';
     palavras[5].subclasse := ARITMETICO;

     palavras[6].palavra := 'mod';
     palavras[6].subclasse := ARITMETICO;

     palavras[7].palavra := '=';
     palavras[7].subclasse := RELACIONAL;

     palavras[8].palavra := '<';
     palavras[8].subclasse := RELACIONAL;

     palavras[9].palavra := '<=';
     palavras[9].subclasse := RELACIONAL;

     palavras[10].palavra := '>';
     palavras[10].subclasse := RELACIONAL;

     palavras[11].palavra := '>=';
     palavras[11].subclasse := RELACIONAL;

     palavras[12].palavra := '<>';
     palavras[12].subclasse := RELACIONAL;

     palavras[13].palavra := 'not';
     palavras[13].subclasse := LOGICO;

     palavras[14].palavra := 'and';
     palavras[14].subclasse := LOGICO;

     palavras[15].palavra := 'or';
     palavras[15].subclasse := LOGICO;

     palavras[16].palavra := ':=';
     palavras[16].subclasse := ATRIBUICAO;


     for i := 1 to n do
     begin
         inserirTabela(palavras[i],operadores, QTDE_OPERADORES);
     end;
end;

procedure cadastrarDelimitadores();
var
   i, n: integer;
   palavras : array[1..QTDE_DELIMITADORES] of lexema;
begin
     for i := 1 to QTDE_DELIMITADORES do
         delimitadores[i] := nil;

     n := 8;
     palavras[1].palavra := ';';
     palavras[1].subclasse := -1;

     palavras[2].palavra := ':';
     palavras[2].subclasse := -1;

     palavras[3].palavra := ',';
     palavras[3].subclasse := -1;

     palavras[4].palavra := '.';
     palavras[4].subclasse := -1;

     palavras[5].palavra := '(';
     palavras[5].subclasse := -1;

     palavras[6].palavra := ')';
     palavras[6].subclasse := -1;

     palavras[7].palavra := '[';
     palavras[7].subclasse := -1;

     palavras[8].palavra := ']';
     palavras[8].subclasse := -1;

     for i := 1 to n do
     begin
         inserirTabela(palavras[i],delimitadores, QTDE_DELIMITADORES);
     end;
end;

function lerCaractere(var c : char) : boolean;
begin
     lerCaractere := true;
     if coluna = 0 then      //ainda não leu nenhum caractere da linha atual
     begin
          if lerDados(textoLeitura) then
          begin
               linha := linha + 1;
               coluna := coluna + 1;
               c := textoLeitura[coluna];
          end
          else
              lerCaractere := false;
     end
     else                    //já leu uma linha do arquivo;
     begin
          textoLeitura[coluna] := #0;
          coluna := coluna + 1;
          c := textoLeitura[coluna];
     end;

     if (c = #0) then   //se chegou ao fim da linha lida, se prepara para ler outra linha
        coluna := 0;

end;

{ANALISADOR LÉXICO}
function analisadorLexico() : token;
var
   t : token;
   q , tam, subclasse, erro: integer;
   c : char;
   palavra : string[255]; //para não ter problemas com o Pascal ao enviar um campo por parametro
begin
     tam := 0; //tamanho do token, usado também para montar o item léxico
     q := 0;   //estado do autômato
     subclasse := 1;

     while(lerCaractere(c)) do      //enquanto tem caractere para ler
     begin
        case q of
             0: begin   //Estado inicial
                     if (c = ' ') or (c = #0) or (c = #9) then  //pulando todos os espaços e quebras de linha
                        continue
                     else
                     if (c in ['0','1','2','3','4','5','6','7','8','9']) then   //início de um número
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        t.linha := linha;
                        t.coluna := coluna;
                        q := 1;
                     end
                     else if (c = '_') or (c in ['a'..'z']) or (c in ['A' .. 'Z']) then //início de um identificador ou palavra reservada
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        t.linha := linha;
                        t.coluna := coluna;
                        q := 5;
                     end
                     else if (c = '{') then //comentário
                     begin
                        q := 16;
                     end
                     else if (c = #39) then //início de string ou char (#39 = ')
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        t.linha := linha;
                        t.coluna := coluna;
                        q := 11;
                     end
                     else   //Qualquer outro caractere, a príncipio consideramos que pode ser um operador ou delimitador
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        t.linha := linha;
                        t.coluna := coluna;
                        q := 7;
                     end;

                end;
             1: begin //lendo um número
                     if (c in ['0','1','2','3','4','5','6','7','8','9']) or (c in ['A' .. 'Z']) or (c in ['a' .. 'z']) then   //enquanto estamos lendo número, continuamos nesse estado
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        if (c in ['A' .. 'Z']) or (c in ['a' .. 'z']) then  //número mal formado
                           erro := ERRO_NUM;
                     end
                     else if (c = '.') then    //se ler um ponto, então esperamos um número real
                     begin
                        tam := tam + 1;
                        palavra[tam] := c;
                        q := 3;
                     end
                     else //se lermos qualquer outro caractere
                     begin
                       //ESTADO FINAL - número inteiro
                       if (coluna <> 0) then
                           coluna := coluna - 1;
                       palavra[0] := chr(tam); //Determina o comprimento da string
                       palavra[tam+1] := #0;
                       t.palavra := palavra;
                       t.classe := NUMERO_INTEIRO;

                       if (erro = ERRO_NUM) then
                       begin
                            t.subclasse := erro;
                       end
                       else
                       begin
                            t.tipoValor := T_INTEGER;
                            val(t.palavra, t.valorInt, erro);
                            if (erro <> 0) then   //aconteceu algum erro, no caso só pde ser q estorou o tamanho do inteiro
                                t.subclasse := ERRO_NUM_MAX;
                       end;
                       break;
                     end;
                end;
             3: begin  //lendo um número real
                       if (c in ['0','1','2','3','4','5','6','7','8','9']) or (c in ['A' .. 'Z']) or (c in ['a' .. 'z']) then //Continua lendo números após o ponto
                       begin
                            tam := tam + 1;
                            palavra[tam] := c;
                            if (c in ['A' .. 'Z']) or (c in ['a' .. 'z']) then  //número mal formado
                               erro := ERRO_NUM;
                       end
                       else //Se lermos qualquer outro caractere
                       begin
                            //ESTADO FINAL - número real
                             if (coluna <> 0) then
                                coluna := coluna - 1;
                             palavra[0] := chr(tam);
                             palavra[tam+1] := #0;
                             t.palavra := palavra;
                             t.classe := NUMERO_REAL;

                             if (erro = ERRO_NUM) then
                             begin
                                 t.subclasse := erro;
                             end
                             else
                             begin
                                  t.tipoValor := T_REAL;
                                  val(t.palavra, t.valorReal, erro);
                                  if (erro <> 0) then   //aconteceu algum erro, no caso só pde ser q estorou o tamanho do real
                                     t.subclasse := ERRO_NUM;
                             end;
                             break;
                       end;
                end;
             5: begin  //lendo um identificador
                       if ((c in ['a'..'z']) or (c in ['A'..'Z']) or (c = '_') or (c in ['0','1','2','3','4','5','6','7','8','9'])) then
                       begin
                          tam := tam + 1;
                          palavra[tam] := c;
                       end
                       else
                       begin
                           //ESTADO FINAL - identificador
                           if (coluna <> 0) then
                                coluna := coluna - 1;
                           palavra[0] := chr(tam);
                           palavra[tam+1] := #0;
                           t.palavra := palavra;

                           if consultarTabela(palavra, subclasse, palavrasReservadas,QTDE_PALAVRAS_RESERVADAS) then //se encontrar na tabela de palavras reservadas
                           begin
                                t.classe := PALAVRA_RESERVADA;
                                t.subclasse := subclasse;
                                if (subclasse = OPERADOR) then
                                begin
                                     if consultarTabela(palavra, subclasse, operadores,QTDE_OPERADORES) then //sendo palavra reservada mas a subclasse é operador, então é um operadores
                                     begin
                                          t.classe := OPERADOR;
                                          t.subclasse := subclasse;
                                     end;
                                end;
                                if (lowercase(t.palavra) = 'true') then
                                begin
                                     t.tipoValor := T_BOOLEAN;
                                     t.valorBool := true;
                                end
                                else if (lowercase(t.palavra) = 'false') then
                                begin
                                     t.tipoValor := T_BOOLEAN;
                                     t.valorBool := false;
                                end;
                           end
                           else
                           begin
                                t.classe := IDENTIFICADOR;
                                if (tam > 63) then //Se o tamanho do identificador é maior, então há um erro de estouro
                                   t.subClasse := ERRO_IDENT_MAX;
                           end;

                           break;
                       end;
                end;
             7: begin  //Operador ou delimitador
                       if not ((c = '_') or (c in ['a'..'z']) or (c in ['A'..'Z']) or (c in ['0','1','2','3','4','5','6','7','8','9']) or (c = ' ') or (c = #0) or (c = #9)) then
                       begin
                           tam := tam + 1;
                           palavra[tam] := c;
                           palavra[tam+1] := #0;
                           palavra[0] := chr(tam);

                           if not((palavra = '>=') or (palavra = '>=') or (palavra = '<>') or (palavra = ':=')) then
                           begin
                                //Estado final - operador ou delimitador
                                tam := tam - 1;
                                palavra[tam+1] := #0;
                                palavra[0] := chr(tam);

                                if (coluna <> 0) then
                                   coluna := coluna - 1;
                               t.palavra := palavra;

                               if consultarTabela(palavra, subclasse, operadores,QTDE_OPERADORES) then //se encontrar na tabela de operadores
                               begin
                                    t.classe := OPERADOR;
                                    t.subclasse := subclasse;
                               end
                               else if  consultarTabela(palavra, subclasse, delimitadores,QTDE_DELIMITADORES) then //se encontrar na tabela de delimitadores
                               begin
                                    t.classe := DELIMITADOR;
                               end
                               else
                                   t.subclasse := ERRO_SIMB_DESCONHECIDO;

                               break;
                           end
                           else
                           begin
                                palavra[tam+1] := #0;
                                palavra[0] := chr(tam);
                                t.palavra := palavra;

                                if consultarTabela(palavra, subclasse, operadores,QTDE_OPERADORES) then //se encontrar na tabela de operadores
                                begin
                                     t.classe := OPERADOR;
                                     t.subclasse := subclasse;
                                end
                                else
                                     t.subclasse := ERRO_SIMB_DESCONHECIDO;
                           end;
                       end
                       else
                       begin
                            //ESTADO FINAL - operador/delimitador
                            if (coluna <> 0) then
                               coluna := coluna - 1;
                               palavra[0] := chr(tam);
                               palavra[tam+1] := #0;
                               t.palavra := palavra;

                               if consultarTabela(palavra, subclasse, operadores,QTDE_OPERADORES) then //se encontrar na tabela de operadores
                               begin
                                    t.classe := OPERADOR;
                                    t.subclasse := subclasse;
                               end
                               else if  consultarTabela(palavra, subclasse, delimitadores,QTDE_DELIMITADORES) then //se encontrar na tabela de delimitadores
                               begin
                                    t.classe := DELIMITADOR;
                               end
                               else
                                   t.subclasse := ERRO_SIMB_DESCONHECIDO;

                               break;
                            end;
                       end;
             11: begin   //String ou char
                       if not (c = #39) then //Se não é um apóstrofo, então é um caractere ou string.
                       begin
                            tam := tam + 1;
                            palavra[tam] := c;
                            q := 12;
                       end
                       else //Se ler um apóstrofo, então é string nula.
                       begin  //ESTADO FINAL - STRING NULA
                            tam := tam + 1;
                            palavra[tam] := c;
                            palavra[0] := chr(tam);
                            palavra[tam+1] := #0;
                            t.palavra := palavra;
                            t.classe := _STRING;
                            t.subclasse := subclasse;
                            t.tipoValor := T_STRING;
                            t.valorString := '';
                            break;
                       end;
                 end;
             12: begin
                      if (c = #39) then //Se leu apenas 1 caractere = _CHAR
                      begin
                           tam := tam + 1;
                           palavra[tam] := c;

                           //ESTADO FINAL - CHAR

                           palavra[0] := chr(tam);
                           palavra[tam+1] := #0;
                           t.palavra := palavra;
                           t.classe := _CHAR;
                           t.subclasse := subclasse;
                           t.tipoValor := T_CHAR;
                           t.valorChar := palavra[2];
                           break;
                      end
                      else //Se ler mais algum caractere, então é uma string.
                      begin
                           tam := tam + 1;
                           palavra[tam] := c;
                           q := 14;
                      end;
                 end;
             14: begin //String
                       if not(c = #39) then
                       begin
                            tam := tam + 1;
                            palavra[tam] := c;
                       end
                       else //Término de leitura de string.
                       begin
                            tam := tam + 1;
                            palavra[tam] := c;

                            //ESTADO FINAL - STRING
                            palavra[0] := chr(tam);
                            if (tam < 255) then
                               palavra[tam+1] := #0;
                            t.palavra := palavra;
                            t.classe := _STRING;
                            t.subclasse := subclasse;
                            if (tam >= 254) then
                               t.subclasse := ERRO_STRING;

                            t.tipoValor := T_STRING;
                            t.valorString := copy(palavra,2,tam-2);
                            break;
                       end;
                 end;
             16: begin //Comentário
                       if not (c = '}') then //Enquanto não termina o comentário, joga-se tudo fora.
                       begin
                            continue;
                       end
                       else //Se o caractere lido for '}', então é fim do comentário. Volta ao estado q0.
                       begin
                            q := 0;
                       end;
                 end;
        end;
     end;
     analisadorLexico := t;
end;

{------------------------------------------------------------------------------}

{variáveis locais da função principal}
var
   i, subclasse, qtdeTokens: integer;
   t : token;
begin
    //Cadastrando as palavras reservadas
    cadastrarPalavrasReservadas();
    cadastrarOperadores();
    cadastrarDelimitadores();

    //Inicializando variáveis
    linha := 0;
    coluna := 0;

    qtdeTokens := 0;

    readln(caminho);
    if abrirArquivo(caminho) then
    begin
       repeat
          t := analisadorLexico();
          if (t.linha <> 0) then
          begin
             qtdeTokens := qtdeTokens + 1;
             tabelaTokens[qtdeTokens] := t;
             write(t.palavra:20,' ',t.classe:4,' ',t.subclasse:4,' ',t.linha:4,' ',t.coluna:4);
             case t.tipoValor of
                 T_INTEGER : write(' ',t.valorInt);
                 T_REAL    : write(' ',t.valorReal);
                 T_CHAR    : write(' ',t.valorChar);
                 T_STRING  : write(' ',t.valorString);
                 T_BOOLEAN : write(' ',t.valorBool);
             end;
             writeln();
          end;
       until t.linha = 0;
    end
    else
        writeln('Problema ao abrir arquivo');
    {
    //Exibindo as listas para verificar se está tudo certo
    writeln('Palavras reservadas: ');
    for i := 1 to QTDE_PALAVRAS_RESERVADAS do
    begin
         write(i,': ');
         mostrarLista(palavrasReservadas[i]);
         writeln();
    end;
    writeln();
    writeln('Operadores: ');
    for i := 1 to QTDE_OPERADORES do
    begin
         write(i,': ');
         mostrarLista(operadores[i]);
         writeln();
    end;
    writeln();
    writeln('Delimitadores: ');
    for i := 1 to QTDE_DELIMITADORES do
    begin
         write(i,': ');
         mostrarLista(delimitadores[i]);
         writeln();
    end;
    writeln();


    //Buscando algumas palavras para ver se a consulta funciona
    writeln(consultarTabela('xor', subclasse, palavrasReservadas,QTDE_PALAVRAS_RESERVADAS));
    writeln(subclasse);
    writeln(consultarTabela('div', subclasse, palavrasReservadas,QTDE_PALAVRAS_RESERVADAS));
    writeln(subclasse);
    writeln(consultarTabela('if', subclasse, palavrasReservadas,QTDE_PALAVRAS_RESERVADAS));
    writeln(subclasse);
    writeln(consultarTabela('else', subclasse, palavrasReservadas,QTDE_PALAVRAS_RESERVADAS));
    writeln(subclasse);
    }
    readkey;
end.
