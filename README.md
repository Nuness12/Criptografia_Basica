A criptografia tem quatro objetivos principais:

● Confidencialidade da mensagem: só o destinatário autorizado deve ser capaz de
extrair o conteúdo da mensagem da sua forma cifrada. Além disso, a obtenção de
informação sobre o conteúdo da mensagem (como uma distribuição estatística de
certos caracteres) não deve ser possível, uma vez que, se o for, torna mais fácil a
análise criptográfica.

● Integridade da mensagem: o destinatário deverá ser capaz de determinar se a
mensagem foi alterada durante a transmissão.

● Autenticação do remetente: o destinatário deverá ser capaz de identificar o
remetente e verificar que foi mesmo ele quem enviou a mensagem.

● não-repúdio ou irretratabilidade do emissor: não deverá ser possível ao emissor
negar a autoria da mensagem.

Nem todas as técnicas garantem todos os objetivos.

Tipos de Tecnicas de Criptografia

2-WAY
Simétricos
Os algoritmos de chave simétrica (ou chave única / secreta) são uma classe de algoritmos
para a criptografia, que usam chaves criptográficas relacionadas para as operações de
cifragem ou decifragem (ou cifra/decifra, ou cifração/decifração).

Assimétricos ( ou de chave pública/privada )
A criptografia de chave pública ou criptografia assimétrica é um método de criptografia que
utiliza um par de chaves: uma chave pública e uma chave privada. A chave pública é
distribuída livremente para todos os correspondentes via e-mail ou outras formas, enquanto
a chave privada deve ser conhecida apenas pelo seu dono.

1-WAY
Hash
Um hash (ou escrutínio) é uma sequência de bits geradas por um algoritmo de dispersão,
em geral representada em base hexadecimal, que permite a visualização em letras e
números (0 a 9 e A a F), representando um nibble cada (4 bits ). O conceito teórico diz que
"hash é a transformação de uma grande quantidade de informações em uma pequena
quantidade de informações".


Veremos isso aplicado em um processo de autenticação de login e senha em um banco de dados!

O objetivo é automatizar os processos de armazenamento de logins, senhas e dicas de senha e o processo de autenticação de um sistema, de forma que a utilização das informações deve se dar da seguinte maneira:
- Uma tabela TBL_CTRL_ACESSO, com os campos citados acima, com 
- Login, não precisa nem deve ser criptografado na base
- Senha, deve ser armazenado com criptografia 1-WAY
- Dica_senha, deve ser armazenado com criptografia 2-WAY

Para concluir este objetivo você precisará criar:
- Uma função, que receba um texto e devolva-o criptografado ( fn_encrypt )
- Outra Funcão, que receba um valor criptografado e o decriptografe ( fn_decrypt )
- Uma função, que receba um texto e o criptografe ( fn_hash ) 🡪 use “SALT”

De forma que tais funções possam ser utilizadas nos exemplos criados para insirir valores na tabela obedecendo às recomendações.

Finalmente:
- Crie uma procedure que: dado um login e senha, devolva “1” se autenticado e “0” caso contrário.
- Crie uma procedure que: dado um login, devolva a dica da senha, decriptografada.
