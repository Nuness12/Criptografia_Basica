--=X=-- --=X=-- --=X=-- --=X=-- --=X=-- --=X=-- 
--=X=-- EXERCÍCIOS
--=X=-- --=X=-- --=X=-- --=X=-- --=X=-- --=X=-- 

--Criando a tabela
CREATE  TABLE TBL_CTRL_ACESSO (
	[LOGIN] VARCHAR(60) NOT NULL
	, [SENHA] VARBINARY(MAX) NOT NULL
	, [DICA_SENHA] VARBINARY(MAX) NULL
	, CONSTRAINT PK_CTRL_ACESSO PRIMARY KEY ( [LOGIN] )
)
GO
--Criando a chave assimétrica ( poderia ser simétrica )
CREATE ASYMMETRIC KEY ChaveAssimetrica002
WITH ALGORITHM = RSA_2048
ENCRYPTION BY PASSWORD = N'Amor123@';
GO

--criando a função de criptografia 2-way
CREATE  FUNCTION dbo.FN_ENCRYPT (
    @inputtext VARCHAR(MAX)
)
RETURNS VARBINARY(MAX)
AS
BEGIN
	Declare @key_ID INT = (select AsymKey_ID('ChaveAssimetrica002'))
    DECLARE @EncryptedText VARBINARY(MAX);

    -- Atribuindo valor e inserindo minha chave_assimetrica
    SET @EncryptedText = EncryptByAsymKey(@key_ID, @inputtext);

    RETURN @EncryptedText;
END;
GO
--Testando a função de criptografia
select dbo.FN_ENCRYPT('oi')
GO
--Criando função de decriptografia
CREATE FUNCTION FN_DECRYPT(
		    @inputtext VARBINARY(MAX)
)
RETURNS VARCHAR(MAX)
AS 
BEGIN
	DECLARE @decryptedString NVARCHAR(MAX);
	Declare @key_ID INT = (select AsymKey_ID('ChaveAssimetrica002'))

	SET @decryptedString = CONVERT(VARCHAR,DecryptByAsymKey(@key_ID,@inputtext, N'Amor123@'));

	return @decryptedString;
END;
GO
--Testando a função de decriptografia
select dbo.FN_DECRYPT(dbo.FN_ENCRYPT('oi'))
GO
--Criando função de criptografia 1-way HASH
ALTER FUNCTION FN_HASH (
    @textoinput VARCHAR(MAX)
)
RETURNS VARBINARY(MAX) 
AS
BEGIN
    ---- ATRIBUINDO O 'SALT' QUE É CONSIDERADO PARA MELHOR SEGURANÇA
    DECLARE @SALT VARCHAR(50) = 'FIT';
    ---- CONCATENANDO NOSSA STRING COM ESSE "TEMPERO"
    DECLARE @VALUE VARCHAR(MAX) = @SALT + @textoinput;

    -- VARIAVEL DE HASH
    DECLARE @hashedValue VARBINARY(64); 

    -- Calcular o hash do texto com salt
    SET @hashedValue = HASHBYTES('SHA1', @VALUE);

    RETURN @hashedValue;
END;


GO
--Testando a função de criptografia de HASH
declare @senha varchar(max) = 'senha'
select dbo.FN_HASH(@senha)
GO

--Inserindo valores nas tabelas para testes:
INSERT INTO TBL_CTRL_ACESSO ( [LOGIN], [SENHA], [DICA_SENHA] )
VALUES ( 'NUNES', dbo.FN_HASH('senha'), dbo.FN_ENCRYPT('aquela lá') )
GO
--Testando valores brutos inseridos na tabela
select * from TBL_CTRL_ACESSO
GO


--Testando valores decriptografados lidos da tabela
select	[login]
		,[senha]
		,CONVERT(VARCHAR,dbo.FN_DECRYPT([dica_senha])) as [dica_senha] 
from TBL_CTRL_ACESSO
GO

ALTER PROCEDURE PR_LOGIN    
    @login VARCHAR(50),
    @senha VARCHAR(50),
    @autenticado BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hashSenha VARCHAR(64);

    -- Calcular o hash da senha fornecida
    SET @hashSenha = dbo.FN_HASH(@senha); 

    -- Verificar se o login e a senha correspondem a um registro na tabela de usuários
    IF EXISTS (SELECT 1 FROM TBL_CTRL_ACESSO WHERE Login = @login AND Senha = @hashSenha)
    BEGIN
        SET @autenticado = 1; -- Define o parâmetro de saída como 1 (autenticado) se o login for bem-sucedido
    END
    ELSE
    BEGIN
        SET @autenticado = 0; -- Define o parâmetro de saída como 0 (não autenticado) se o login falhar
    END
END;


--testando procedure de login
DECLARE @result BIT
	--autenticado
	EXEC PR_LOGIN 'NUNES', 'senha', @result OUTPUT
	SELECT CASE WHEN @result = 1 then 'Autenticado' else 'Não autenticado' end
	--não autenticado
	EXEC PR_LOGIN 'NUNES', 'senha errada', @result OUTPUT
	SELECT CASE WHEN @result = 1 then 'Autenticado' else 'Não autenticado' end
GO
-- CRIANDO PROCEDURE PARA ESQUECI SENHA
ALTER PROCEDURE PR_ESQUECI_SENHA
    @LOGIN VARCHAR(MAX),
    @result VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @DICA VARBINARY(MAX);
    DECLARE @VALUE VARCHAR(MAX);

    -- Obter a dica de senha criptografada para o login fornecido
    SELECT @DICA = DICA_SENHA
    FROM TBL_CTRL_ACESSO
    WHERE Login = @LOGIN;

    -- Verificar se a dica de senha foi encontrada
    IF @DICA IS NOT NULL
    BEGIN
        -- Descriptografar a dica de senha
        SET @VALUE = dbo.FN_DECRYPT(@DICA);

        -- Atribuir a dica de senha ao parâmetro de saída
        SET @result = @VALUE;
    END
    ELSE
    BEGIN
        -- Se não houver dica de senha para o login fornecido, retornar uma mensagem de erro
        SET @result = NULL; -- Atribuir NULL ao parâmetro de saída
        RAISERROR ('Dica de senha não encontrada para o login fornecido.', 16, 1);
    END
END;
GO


--Testando a procedure esqueci senha
DECLARE @result VARCHAR(60) 
EXEC PR_ESQUECI_SENHA 'NUNES', @result OUTPUT
SELECT 'Sua dica da senha é: "' + @result + '"'
GO







