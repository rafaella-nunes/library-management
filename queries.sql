 CREATE TABLE IF NOT EXISTS autores (
    id INT PRIMARY KEY,
    nome VARCHAR(255)
);

  CREATE TABLE IF NOT EXISTS livros (
    id INT PRIMARY KEY,
    titulo VARCHAR(255),
    autorID INT,
    genero VARCHAR(100),
    ano_publicacao INT,
    ISBN VARCHAR(20),
    FOREIGN KEY (autorID) REFERENCES autores(autorID)
);

 CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(100),
    data_cadastro DATE
);

 CREATE TABLE IF NOT EXISTS emprestimos (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_emprestimo DATE,
    data_devolucao_programada DATE,
    data_devolucao DATE,
    status VARCHAR(50),
    FOREIGN KEY (livroID) REFERENCES livros(livroID),
    FOREIGN KEY (userID) REFERENCES users(userID)
);

 CREATE TABLE IF NOT EXISTS reservas (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_reserva DATE,
    data_disponivel DATE,
    FOREIGN KEY (livroID) REFERENCES livros(livroID),
    FOREIGN KEY (userID) REFERENCES users(userID)
);


 CREATE TABLE IF NOT EXISTS notificacoes (
    notificacaoID SERIAL,
    userID INT,
    mensagem TEXT,
    data_envio DATETIME,
    FOREIGN KEY (userID) REFERENCES users(id)
);



--Functions


CREATE OR REPLACE FUNCTION calcular_multa(data_devolucao DATE, data_devolucao_programada DATE) 
RETURNS DECIMAL(10, 2) AS $$
BEGIN
    DECLARE multa DECIMAL(10, 2);
    
    IF data_devolucao > data_devolucao_programada THEN
        SET multa = DATEDIFF(data_devolucao, data_devolucao_programada) * 2.00; -- multa diária R$2.00
    ELSE
        SET multa = 0.00;
    END IF;
    
    RETURN multa;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificar_disponibilidade(livros.id) 
RETURNS BOOLEAN AS $$
BEGIN
    DECLARE disponivel BOOLEAN;
    
    SELECT COUNT(*)
    INTO disponivel
    FROM emprestimos
    WHERE livro.id = livro.id AND Status = 'Emprestado';
    
    RETURN NOT disponivel;
END;
$$ 
LANGUAGE plpgsql;

--Trigger

CREATE OR REPLACE FUNCTION att_espera()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Devolvido' THEN
        -- verificando se há reservas pendentes para o livro
        DECLARE livroID INT;
        DECLARE userID INT;
        
        SET livroID = NEW.emprestimos.livroID;
        
        SELECT userID INTO userID
        FROM reservas
        WHERE livroID = livroID
        ORDER BY data_reserva
        LIMIT 1;
        
        IF userID IS NOT NULL THEN
            -- Enviar notificação para o próximo usuário (envio de e-mail)
            INSERT INTO notificacoes (userID, mensagem, data_envio) VALUES (userID, 'O livro que você reservou está disponível.', NOW());
        END IF;
    END IF;
END;
$$
LANGUAGE plpgsql;
--Trigger

CREATE TRIGGER att_lista_espera
AFTER UPDATE ON emprestimos
EXECUTE FUNCTION att_espera();


CREATE OR REPLACE VIEW livros_emprestados AS
SELECT
    E.id,
    L.titulo AS titulo_livro,
    A.nome AS nome_autor,
    U.nome AS nome_user,
    E.data_emprestimo,
    E.data_devolucao_programada,
    E.status
FROM emprestimos E
JOIN livros L ON E.livroID = L.id
JOIN autores A ON L.autorID = A.id
JOIN usuarios U ON E.userID = U.id
WHERE E.status = 'Emprestado';


